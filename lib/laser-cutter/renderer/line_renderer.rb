module Laser
  module Cutter
    module Renderer
      class LineRenderer < AbstractRenderer
        def line
          subject
        end
        def render pdf = nil
          pdf.stroke { pdf.line [line.point1.x, line.point1.y].map(&:mm),
                                [line.point2.x, line.point2.y].map(&:mm)}

        end
      end
    end
  end
end
