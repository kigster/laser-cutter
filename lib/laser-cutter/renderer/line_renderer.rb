module Laser
  module Cutter
    module Renderer
      class LineRenderer < AbstractRenderer
        def line
          subject
        end
        def render pdf = nil
          pdf.stroke { pdf.line [line.p1.x, line.p1.y].map(&:mm),
                                [line.p2.x, line.p2.y].map(&:mm)}

        end
      end
    end
  end
end
