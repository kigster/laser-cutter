module Laser
  module Cutter
    module Renderer
      class RectRenderer < BaseRenderer
        alias_method :rect, :subject
        def render(pdf)
          rect.sides.each do |side|
            LineRenderer.new(config, side).render(pdf)
          end
        end
      end
    end
  end
end
