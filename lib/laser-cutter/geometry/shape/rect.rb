module Laser
  module Cutter
    module Geometry
      class Rect < Line

        attr_accessor :sides, :vertices

        def self.[](p1, p2)
          Rect.new(p1, p2)
        end

        def self.create(point, w, h, name = nil)
          r = Rect.new(point, Point[point.x + w, point.y + h])
          r.name = name
          r
        end

        def self.from_line(line)
          Rect.new(line.p1, line.p2)
        end

        def initialize(*args)
          super(*args)
          relocate!
        end

        def relocate!
          super
          self.vertices = []
          vertices << p1
          vertices << p1.plus(w, 0)
          vertices << p2
          vertices << p1.plus(0, h)
          self.sides = []
          vertices.each_with_index do |v, index|
            sides << Line.new(v, vertices[(index + 1) % vertices.size])
          end
          self
        end

        def w
          p2.x - p1.x
        end

        def h
          p2.y - p1.y
        end

        def to_s
          "#{sprintf "%3d", w}(w)x#{sprintf "%3d", h}(h) @ #{position.to_s}"
        end

        def to_a
          [[p1.x, p1.y], [p2.x, p2.y]]
        end
      end

    end

  end
end
