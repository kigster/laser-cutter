module Laser
  module Cutter
    module Geometry
      class Shape
        attr_accessor :position

        def position
          @position ||= Point.new(0, 0)
        end

        def move_to new_point
          self.position = new_point
          self
        end
      end
    end
  end
end

require_relative 'shape/line'
require_relative 'shape/rect'
