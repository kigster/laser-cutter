# frozen_string_literal: true

module Laser
  module Cutter
    # The types of the attributes of {Options}. Each one coerces what a form
    # or a command line sends, Strings mostly, and rejects what it cannot use.
    module Types
      include Dry.Types()

      # Whether a value was left out: nil, or the empty String of a blank form field.
      #
      # @param value [Object]
      # @return [Boolean]
      def self.blank?(value)
        value.nil? || Dry::Types::Undefined.equal?(value) || (value.respond_to?(:empty?) && value.empty?)
      end

      # One of a few words, given as a String or a Symbol. Blank means the default.
      #
      # @param values [Array<String>] the words allowed
      # @param default [String] the word a blank value stands for
      # @return [Dry::Types::Type]
      def self.choice(values, default:)
        String.default(default).enum(*values).constructor { |value| blank?(value) ? Dry::Types::Undefined : value.to_s }
      end

      # A type that also takes nil, and reads a blank value as nil.
      #
      # @param type [Dry::Types::Type]
      # @return [Dry::Types::Type]
      def self.optional(type)
        type.optional.constructor { |value| blank?(value) ? nil : value }
      end

      # A size of the box or of its material: a number above zero.
      Length = Coercible::Float.constrained(gt: 0)

      # A distance that may be zero, such as the kerf or a margin.
      Allowance = Coercible::Float.constrained(gteq: 0)

      # The units every dimension is in.
      Units = choice(%w[in mm], default: 'in')

      # How the lid joins the walls, see Box::LIDS.
      Lid = choice(Box::LIDS.map(&:to_s), default: 'full')

      # The way the page is turned, for a PDF.
      PageLayout = choice(%w[portrait landscape], default: 'portrait')

      # The kind of file to draw.
      Format = Coercible::String.constructor(&:downcase).enum(*Renderer::FORMATS.keys)

      # The name of a page size a PDF can take, such as A4 or LETTER.
      PageSize = Coercible::String.constructor(&:upcase).enum(*PageManager::SIZES.keys)
    end
  end
end
