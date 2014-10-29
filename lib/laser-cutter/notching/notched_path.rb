module Laser
  module Cutter
    module Notching
      class NotchedPath
        attr_accessor :lines, :vertices, :corner_boxes
        def initialize(vertices = [])
          @vertices = vertices
          @lines = []
          @corner_boxes= []
        end

        def << value
          self.vertices << value
        end

        def [] value
          self.vertices[value]
        end

        def size
          self.vertices.size
        end

        def create_lines
          self.vertices.each_with_index do |v, i|
            if v != vertices.last
              self.lines << Geometry::Line.new(v, vertices[i+1])
            end
          end
          self.corner_boxes.each do |box|
            box.relocate!
            self.lines << box.sides
          end

          self.lines.flatten!
          self.lines
        end

      end

    end

  end
end

