module Laser
  module Cutter
    module Geometry
      class Line < Shape
        attr_accessor :point1, :point2

        def initialize(p1, p2)
          self.point1 = p1
          self.point2 = p2
        end
      end
    end
  end
end
