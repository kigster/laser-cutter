module Laser
  module Cutter
    module Geometry
      class NotchedPath
        attr_accessor :lines, :vertices
        def initialize
          @lines = []
          @vertices = []
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
      end

    end

  end
end

