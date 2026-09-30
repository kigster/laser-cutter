# frozen_string_literal: true

require 'victor'

module Laser
  module Cutter
    module Renderer
      # Writes the box as an SVG sized in the configuration's own units. It
      # fits the page to the box, and carries the metadata as a <desc>
      # instead of drawing it.
      class SvgRenderer < Base
        def initialize(config)
          super
          self.subject = Laser::Cutter::Box.new(config)
        end

        # @return [Array<Geometry::Line>] every line to cut, computed once
        def lines
          @lines ||= subject.generate_notches
        end

        # @return [Integer] how many lines {#render} draws, and yields
        def total
          lines.size
        end

        # Writes the file, yielding after each line drawn.
        def render
          svg = Victor::SVG.new(width: "#{width}#{units}", height: "#{height}#{units}", viewBox: "0 0 #{width} #{height}")
          svg.element(:desc, description) if config.metadata
          lines.each do |line|
            svg.line(**coordinates(line), stroke: "##{config[:color] || BLACK}", stroke_width: config.stroke)
            yield line if block_given?
          end
          File.write(config.file, svg.render)
        end

        private

        def margin
          config.margin.to_f
        end

        def width
          (subject.enclosure.p2.x + (2 * margin)).round(5)
        end

        def height
          (subject.enclosure.p2.y + (2 * margin)).round(5)
        end

        # SVG counts y down from the top, the box geometry up from the bottom.
        def coordinates(line)
          { x1: (line.p1.x + margin).round(5), y1: (height - margin - line.p1.y).round(5),
            x2: (line.p2.x + margin).round(5), y2: (height - margin - line.p2.y).round(5) }
        end

        def description
          fields = MetaRenderer::META_KEYS.filter_map { |key| "#{key}: #{config[key]}" if config[key] }
          "Made with laser-cutter v#{VERSION}. #{fields.join(', ')}"
        end
      end
    end
  end
end
