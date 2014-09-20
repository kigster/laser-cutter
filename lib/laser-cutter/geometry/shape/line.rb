module Laser
  module Cutter
    module Geometry
      class Line < Shape
        attr_accessor :point1, :point2

        def initialize(p1, p2)
          self.point1 = p1
          self.point2 = p2
        end

        def relocate!
          dx = point2.x - point1.x
          dy = point2.y - point1.y

          point1 = position

          point2.x = point1.x + dx
          point2.y = point1.y + dy
        end

        def to_s
          "#{point1}->#{point2}"
        end
      end

    end
  end
end
