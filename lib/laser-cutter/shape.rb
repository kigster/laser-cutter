module Laser
  module Cutter
    class Shape
      attr_accessor :position # Coordinate
      def position
        @position ||= Coordinate.new(0,0)
      end

      def x
        position.x
      end
      def y
        position.y
      end

      def move_to x, y
        self.position.x = x
        self.position.y = y
        self
      end
    end
  end
end
require_relative '../laser-cutter/shape/line'
require_relative '../laser-cutter/shape/rect'
