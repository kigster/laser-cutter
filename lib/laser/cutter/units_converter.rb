# frozen_string_literal: true

module Laser
  module Cutter
    class UnitsConverter
      def self.mm2in(value)
        (0.039370079 * value).round(5)
      end

      def self.in2mm(value)
        (25.4 * value).round(5)
      end
    end
  end
end
