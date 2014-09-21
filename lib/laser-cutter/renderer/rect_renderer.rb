module Laser
  module Cutter
    module Renderer
      class RectRenderer < AbstractRenderer
        def rect
          subject
        end

        def render pdf
          rect.sides.each do |side|
            LineRenderer.new(side, options).render(pdf)
          end
        end
      end
    end
  end
end
