require_relative '../tuple'
module LaserCutter
  module Geometry
    class Point < Tuple
      ORIGIN = self.new(0, 0)

      def self.[](*array)
        Point.new *array
      end
    end
  end
end
