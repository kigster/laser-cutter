module Laser
  module Cutter
    module Geometry
      class Line < Shape

        def self.[](*array)
          self.new *array
        end

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

        def overlaps?(another)
          xs, ys = sorted_coords(another)
          return false unless another.kind_of?(self.class)
          return false unless xs.all?{|x| x == xs[0] } || ys.all?{|y| y == ys[0] }
          return false if xs[0][1] < xs[1][0] || xs[0][0] > xs[1][1]
          return false if ys[0][1] < ys[1][0] || ys[0][0] > ys[1][1]
          true
        end

        def is_part_of?(another)
          xs, ys = sorted_coords(another)
          overlaps?(another) &&
            (xs[0][0] >= xs[1][0] || xs[0][1] <= xs[1][1]) &&
            (ys[0][0] >= ys[1][0] || ys[0][1] <= ys[1][1])
        end

        def sorted_coords(another)
          xs = [[p1.x, p2.x].sort, [another.p1.x, another.p2.x].sort]
          ys = [[p1.y, p2.y].sort, [another.p1.y, another.p2.y].sort]
          return xs, ys
        end

        def xor(another)
          return nil unless overlaps?(another)
          xs, ys = sorted_coords(another)
          xs.flatten!.sort!
          ys.flatten!.sort!

          [ Line.new(Point[xs[0], ys[0]], Point[xs[1], ys[1]]),
            Line.new(Point[xs[2], ys[2]], Point[xs[3], ys[3]])]
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
          "#{self.class.name.gsub(/.*::/,'').downcase} #{p1}=>#{p2}"
        end

        def eql?(other)
          (other && other.respond_to?(:p1) && other.p1.eql?(p1) && other.p2.eql?(p2)) ||
          (other && other.respond_to?(:p2) && other.p2.eql?(p1) && other.p1.eql?(p2))
        end

        def normalized
          p1 < p2 ? Line.new(p1, p2) : Line.new(p2, p1)
        end

        def <=>(other)
          n1 = self.normalized
          n2 = other.normalized
          n1.p1.eql?(n2.p1) ? n1.p2 <=> n2.p2 : n1.p1 <=> n2.p1
        end

        def < (other)
          self.p1 == other.p1 ? self.p2 < other.p2 : self.p1 < other.p1
        end

        def > (other)
          self.p1 == other.p1 ? self.p2 > other.p2 : self.p1 > other.p1
        end

        def hash
          [p1.to_a, p2.to_a].sort.hash
        end

        def clone
          self.class.new(p1, p2)
        end

      end

    end
  end
end
