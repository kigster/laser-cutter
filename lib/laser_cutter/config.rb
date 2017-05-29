require 'active_model'
require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
require 'forwardable'

module LaserCutter
  class Config

    DEFAULTS = Hashie::Mash.new({
                                  margin:  3.0,
                                  stroke:  0.025,
                                  padding: 3.0,
                                  kerf:    0.051,
                                })


    UNITS_TO_MM_MULTIPLIER = {
      inches: 25.4,
      meters: 1000,
      cm:     100,
      feet:   304.8,
      yard:   914.41,
    }

    RENDER_ATTRS = %i(margin padding stroke).freeze
    BOX_ATTRS    = %i(width height depth thickness notch kerf).freeze


    class AbstractComponent
      include ActiveModel::Model
      attr_reader :errors

      def initialize(*args, **opts, &block)
        super(opts)
        @errors = ActiveModel::Errors.new(self)
      end

      def validate!
        self.class.instance_variables.each { |a| errors.add(a, 'cannot be nil') if a.nil? }
      end
    end


    class Render < AbstractComponent
      attr_accessor *RENDER_ATTRS
    end


    class Box < AbstractComponent
      attr_accessor *BOX_ATTRS
    end


    class << self
      def create(options)
        self.new(options)
      end

      def supported_units
        UNITS_TO_MM_MULTIPLIER.keys.map(&:to_s).join(', ')
      end
    end


    attr_reader :errors, :box, :render, :options

    extend Forwardable
    def_delegators :@box, *BOX_ATTRS
    def_delegators :@render, *RENDER_ATTRS

    # Everything is stored in the metric system.  Values converted from inches on input.
    def initialize(*args, **opts, &block)
      Hashie::Extensions::SymbolizeKeys.symbolize_keys!(opts)

      convert_units(opts)  # convert all numeric arguments to millimeters.

      @options = DEFAULTS.merge(opts)

      @errors = ActiveModel::Errors.new(self)

      @render = create_component(Render, RENDER_ATTRS, *args, **opts, &block)
      @box    = create_component(Box, BOX_ATTRS, *args, **opts, &block)
    end

    def validate!
      self.render.validate!
      self.box.validate!
      [ render.errors.to_a, box.errors.to_a].flatten
    end

    private

    def convert_units(opts)
      units = opts.keys & UNITS_TO_MM_MULTIPLIER.keys
      unless (units).empty?
        raise ArgumentError, 'Can not use more than one unites specification' if units.size > 1
        opts.transform_values { |x| transform_numeric_options(x, UNITS_TO_MM_MULTIPLIER[units.first]) }
        opts.delete(:inches)
      end
    end

    def create_component(klazz, attributes, *args, **opts, &block)
      opts = opts.dup
      opts.delete_if { |key, *| !attributes.include?(key.to_sym) }
      klazz.new(*args, **opts, &block)
    end


    def transform_numeric_options(x, multiplier)
      begin
        f = Float(x)
      rescue ArgumentError
        f = x
      end
      f.is_a?(Float) ? (x * multiplier) : x
    end

  end
end

