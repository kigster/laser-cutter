# frozen_string_literal: true

module Laser
  module Cutter
    # Everything a box can be asked for, typed. This is what a Ruby program
    # hands to {Laser::Cutter.render} or {Laser::Cutter.write}.
    #
    # Values are coerced, so the Strings of a web form will do, and an
    # instance cannot be changed: #new(lid: :plain) returns a changed copy.
    # Keys may be Strings or Symbols. A key it does not
    # know, a value of the wrong type or a dimension left out all raise,
    # at once, before anything is drawn.
    #
    # The distances left nil take the default for the units: a kerf of
    # 0.0024in, a margin of 0.125in, a padding of 0.1in, a stroke of 0.001in,
    # and a notch three times the thickness.
    #
    # @example A box in millimeters, with a plain lid, as an SVG
    #   options = Laser::Cutter::Options.new(width: 70, height: 20, depth: 50, thickness: 4.3,
    #                                        units: :mm, lid: :plain, format: :svg)
    #   options.lid                 # => "plain"
    #   Laser::Cutter.render(options) # => "<svg ..."
    #
    # @raise [MissingOption] when width, height, depth or thickness is left out
    # @raise [InvalidOption] when a value cannot be used, or a key is not an option
    class Options < Dry::Struct
      # The dimensions a box cannot be drawn without.
      REQUIRED = %i[width height depth thickness].freeze

      # The longest list of allowed values an error spells out.
      MAXIMUM_CHOICES = 5

      transform_keys(&:to_sym)
      schema schema.strict

      # @!attribute [r] width
      #   @return [Float] internal width of the box
      attribute :width, Types::Length

      # @!attribute [r] height
      #   @return [Float] internal height of the box
      attribute :height, Types::Length

      # @!attribute [r] depth
      #   @return [Float] internal depth of the box
      attribute :depth, Types::Length

      # @!attribute [r] thickness
      #   @return [Float] thickness of the material
      attribute :thickness, Types::Length

      # @!attribute [r] notch
      #   @return [Float, nil] notch length, a guide only; nil for three times the thickness
      attribute? :notch, Types.optional(Types::Length)

      # @!attribute [r] kerf
      #   @return [Float, nil] width of the cut; nil for the default
      attribute? :kerf, Types.optional(Types::Allowance)

      # @!attribute [r] units
      #   @return [String] "in" or "mm", the units of every distance here
      attribute :units, Types::Units

      # @!attribute [r] lid
      #   @return [String] "full", "back" or "plain": notched on every side, into the back wall only, or on no side
      attribute :lid, Types::Lid

      # @!attribute [r] format
      #   @return [String, nil] "pdf" or "svg"; nil for a PDF, or for what the extension of the file says
      attribute? :format, Types.optional(Types::Format)

      # @!attribute [r] file
      #   @return [String, nil] the file {Laser::Cutter.write} writes
      attribute? :file, Types.optional(Types::Coercible::String)

      # @!attribute [r] margin
      #   @return [Float, nil] margin from the edge of the page; nil for the default
      attribute? :margin, Types.optional(Types::Allowance)

      # @!attribute [r] padding
      #   @return [Float, nil] space between the panels; nil for the default
      attribute? :padding, Types.optional(Types::Allowance)

      # @!attribute [r] stroke
      #   @return [Float, nil] stroke width of the lines; nil for the default
      attribute? :stroke, Types.optional(Types::Length)

      # @!attribute [r] page_size
      #   @return [String, nil] a page size such as "A4", for a PDF; nil to fit the box
      attribute? :page_size, Types.optional(Types::PageSize)

      # @!attribute [r] page_layout
      #   @return [String] "portrait" or "landscape", for a PDF
      attribute :page_layout, Types::PageLayout

      # @!attribute [r] metadata
      #   @return [Boolean] whether the settings of the box are printed on the page
      attribute :metadata, Types::Params::Bool.default(true)

      # @!attribute [r] inside_box
      #   @return [Boolean] whether the box is also drawn without kerf, in red
      attribute :inside_box, Types::Params::Bool.default(false)

      class << self
        # @param attributes [Hash, Options] the options, by name
        # @return [Options]
        # @raise [MissingOption, InvalidOption]
        def new(attributes = {}, *)
          return attributes if attributes.is_a?(self)

          require_dimensions!(attributes) if attributes.respond_to?(:to_h)
          super
        rescue Dry::Struct::Error => e
          raise InvalidOption, explain(e)
        end

        private

        def require_dimensions!(attributes)
          given = attributes.to_h.transform_keys(&:to_sym)
          missing = REQUIRED.select { |name| Types.blank?(given[name]) }
          return if missing.empty?

          raise MissingOption, "#{missing.join(', ')} #{missing.size > 1 ? 'are' : 'is'} required, but missing."
        end

        # Says which option was refused, and what it may be when that is a short list.
        def explain(error)
          cause = error.cause
          return error.message.sub(/\A\[.*?\] /, '') unless cause.respond_to?(:key) && cause.respond_to?(:value)

          choices = choices_of(schema.key(cause.key).type)
          allowed = choices && choices.size <= MAXIMUM_CHOICES ? ", but must be one of: #{choices.join(', ')}" : ''
          "#{cause.key} cannot be #{cause.value.inspect}#{allowed}."
        end

        # The words an attribute may be, found under whatever wraps its type.
        #
        # @return [Array<String>, nil] nil when the attribute is not one of a list
        def choices_of(type)
          return type.values if type.respond_to?(:values)

          inner = %i[right type].find { |name| type.respond_to?(name) }
          choices_of(type.public_send(inner)) if inner
        end
      end

      # @return [Configuration] the same settings, as the renderers take them
      def to_configuration
        Configuration.new(to_h.except(:format, :inside_box).merge(debug: inside_box))
      end
    end
  end
end
