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
          self
        end

        def center
          Point.new((point2.x + point1.x) / 2, (point2.y + point1.y) / 2)
        end

        def length
          Math.sqrt((point2.x - point1.x)**2 + (point2.y - point1.y)**2)
        end

        def to_s
          "#{point1}->#{point2}"
        end
      end

    end
  end
end
