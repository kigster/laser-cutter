module Laser
  module Cutter
    module Geometry
      class NotchedPath
        attr_accessor :lines, :vertices
        def initialize(vertices = [])
          @vertices = vertices
          @lines = []
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
          self.lines = []
          self.vertices.each_with_index do |v, i|
            if v != vertices.last
              self.lines << Line.new(v, vertices[i+1])
            end
          end
          lines
        end

      end

    end

  end
end
