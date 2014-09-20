module Laser
  module Cutter
    module Geometry
      class Shape
        attr_accessor :position

        def position
          @position ||= Point.new(0, 0)
        end

        def x= value
          position.x = value
        end

        def y= value
          position.y = value
        end

        def move_to new_point
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
end

require_relative 'shape/line'
require_relative 'shape/rect'
