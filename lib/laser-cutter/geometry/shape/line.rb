module Laser
  module Cutter
    module Geometry
      class Line < Shape
        attr_accessor :p1, :p2

        def initialize(point1, point2 = nil)
          if point1.is_a?(Hash)
            options = point1
            self.p1 = Point.new(options[:from])
            self.p2 = Point.new(options[:to])
          else
            self.p1 = point1.clone
            self.p2 = point2.clone
          end
          self.position = p1.clone
          raise 'Both points are required for line definition' unless (p1 && p2)
        end

        def relocate!
          dx = p2.x - p1.x
          dy = p2.y - p1.y

          self.p1 = position.clone
          self.p2 = Point[p1.x + dx, p1.y + dy]
          self
        end

        def center
          Point.new((p2.x + p1.x) / 2, (p2.y + p1.y) / 2)
        end

        def length
          Math.sqrt((p2.x - p1.x)**2 + (p2.y - p1.y)**2)
        end

        def to_s
          "#{self.class.name}:{#{p1}=>#{p2}}"
        end

        def eql?(other)
          (other.p1.eql?(p1) && other.p2.eql?(p2)) ||
          (other.p2.eql?(p1) && other.p1.eql?(p2))
        end

        def clone
          self.class.new(p1, p2)
        end

      end

    end
  end
end
