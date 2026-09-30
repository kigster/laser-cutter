# frozen_string_literal: true

module Laser
  module Cutter
    module Renderer
      class BoxRenderer < Base
        alias_method :box, :subject

        def initialize(config)
          super
          self.subject = Laser::Cutter::Box.new(config)
        end

        def ensure_space_for(rect)
          coords = [rect.p2.x, rect.p2.y].map{ |a| page_manager.value_from_units(a) }
          box.metadata = Geometry::Point.new(coords)
        end

        def enclosure
          box.enclosure
        end

        # @return [Array<Geometry::Line>] every line to cut, computed once
        def lines
          @lines ||= box.generate_notches
        end

        # Draws the box, yielding after each line so a caller can count them.
        def render(pdf = nil)
          pdf.line_width = config.stroke.send(units)
          pdf.stroke_color config[:color] || BLACK
          lines.each do |line|
            LineRenderer.new(config, line).render(pdf)
            yield line if block_given?
          end
        end
      end
    end
  end
end
