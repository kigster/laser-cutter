module Laser
  module Cutter
    module Geometry
      class Rect < Shape
        attr_accessor :w, :h, :name
        attr_accessor :sides, :vertices

        def initialize(point, w, h, name = nil)
          self.position = point.clone
          self.w = w
          self.h = h
          self.name = name
          relocate!
        end

        def relocate!
          self.vertices = []
          vertices << position.move_by(0, 0)
          vertices << position.move_by(w, 0)
          vertices << position.move_by(w, h)
          vertices << position.move_by(0, h)
          self.sides = []
          vertices.each_with_index do |v, index|
            sides << Line.new(v, vertices[(index + 1) % vertices.size])
          end
        end

        def to_s
          "#{sprintf "%3d", w}(w)x#{sprintf "%3d", h}(h) @ #{position.to_s} #{name}"
        end

      end

    end

  end
end
