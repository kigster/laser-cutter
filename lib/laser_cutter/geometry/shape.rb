require_relative 'tuple/point'
module LaserCutter
  module Geometry
    class Shape
      attr_accessor :position, :name

      def position
        @position ||= Point.new(0, 0)
      end

      # @param [Object] value
      def x= value
        position.x = value
      end

      def x
        position.x
      end

      def y=(value)
        position.y = value
      end

      def y
        position.y
      end

      def move_to(new_point)
        self.position = new_point
        relocate!
        self
      end

      # Implement in each shape to move to the new pointd
      def relocate!
        raise 'Abstract method'
      end
    end
  end
end

