module Laser
  module Cutter
    module Renderer
      class AbstractRenderer < Struct.new(:subject)
        def render pdf = nil
          raise 'Abstract method'
        end
      end
    end
  end
end

require 'laser-cutter/renderer/line_renderer'
require 'laser-cutter/renderer/rect_renderer'
require 'laser-cutter/renderer/box_renderer'
