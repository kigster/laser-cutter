# frozen_string_literal: true

module Laser
  module Cutter
    class Configuration < Hashie::Mash
      include ::Hashie::Extensions::Mash::SymbolizeKeys

      SIZE_REGEXP = %r{[\d.]+x[\d.]+x[\d.]+/[\d.]+(/[\d.]+)?}

      FLOATS   = %i(width height depth thickness notch margin padding stroke kerf).freeze
      NON_ZERO = %i(width height depth thickness stroke).freeze
      REQUIRED = %i(width height depth thickness notch file).freeze

      @mutex = Mutex.new

      class << self
        attr_accessor :mutex, :defaults

        def compute_defaults!
          mutex.synchronize do
            if defined?(@defaults)
              @defaults
            else
              @defaults = compute_metric_units!
            end
          end.dup
        end

        def compute_metric_units!
          defaults = Hashie::Mash.new({
                                        units:       :in,
                                        page_layout: 'portrait',
                                        metadata:    true,
                                        in:          {
                                          kerf:    0.0024, # smallest kerf for thin material, usually it's more than that.
                                          margin:  0.125,
                                          padding: 0.1,
                                          stroke:  0.001,
                                        }
                                      })

          defaults[:mm] = defaults[:in].map { |k, v| [k, UnitsConverter.in2mm(v)] }.to_h
          defaults
        end
      end

      compute_defaults!

      def initialize(options = {})
        ::Hashie::Extensions::SymbolizeKeys.symbolize_keys!(options)

        options.delete_if { |_k, v| v.nil? }
        if options[:units]
          unit = options[:units].to_sym
          unless self.class.defaults.key?(unit) || self.class.defaults.key?(unit.to_s)
            options.delete(:units)
          end
        end

        super(self.class.defaults.merge(options))

        if box =~ SIZE_REGEXP
          dim, self[:thickness], self[:notch]       = self[:box].split('/')
          self[:width], self[:height], self[:depth] = dim.split('x')
          delete(:box)
        end
        FLOATS.each do |k|
          self[k] = self[k].to_f if self[k].is_a?(String)
        end
        merge!(self.class.defaults[self[:units].to_sym].merge(self))
        self[:notch] = (self[:thickness] * 3.0).round(5) if self[:thickness] && self[:notch].nil?
      end

      def validate!
        missing = []
        REQUIRED.each { |k| missing << k if self[k].nil? }
        raise MissingOption, "#{missing.join(', ')} #{missing.size > 1 ? 'are' : 'is'} required, but missing." unless missing.empty?

        zeros = []
        NON_ZERO.each { |k| zeros << k if self[k] == 0 }
        raise ZeroValueNotAllowed, "#{zeros.join(', ')} #{zeros.size > 1 ? 'are' : 'is'} required, but is zero." unless zeros.empty?
      end

      def change_units(new_units)
        new_units = new_units.to_sym
        return if new_units == units.to_sym
        return unless self.class.defaults.key?(new_units)

        k = units.to_sym == :in ? UnitsConverter.in2mm(1.0) : UnitsConverter.mm2in(1.0)

        FLOATS.each do |field|
          next if send(field).nil?

          send("#{field}=", (send(field) * k).round(5))
        end

        self.units = new_units
      end
    end
  end
end
