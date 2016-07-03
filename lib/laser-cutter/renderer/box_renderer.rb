# encoding: utf-8
require 'json'
module Laser
  module Cutter
    module Renderer
      class BoxRenderer < Base
        alias_method :box, :subject

        def initialize(config)
          super(config)
          self.subject = Laser::Cutter::Box.new(config)
        end

        def ensure_space_for(rect)
          coords              = [rect.p2.x, rect.p2.y].map { |a| page_manager.value_from_units(a) }
          box.position_offset = Geometry::Point.new(coords)
        end

        def enclosure
          box.enclosure
        end

        # @param [Object] pdf
        def render(pdf = nil)
          renderer = self
          STDERR.puts 'Rendering BEGIN' if renderer.config.debug
          pdf.instance_eval do
            self.line_width = renderer.config.stroke.send(renderer.config.units.to_sym)
            stroke_color renderer.config[:color] || BLACK

            # this ensures that each face is a connected line / polygon instead
            # of a set of disjointed lines.
            renderer.box.notches.values.each do |notches|
              lines = Laser::Cutter::Geometry::LineJoiner.new(notches).lines
              stroke do
                last_point = [ lines.first.p1.x, lines.first.p1.y ]
                move_to *(last_point.map { |p| p.send(renderer.units) })
                count = 0
                lines.each do |line|
                  count += 1
                  stroke_color count.even? ? BLACK : BLUE
                  next_point = [ line.p2.x, line.p2.y ]
                  STDERR.puts "Drawing contiguous line from #{last_point} to #{next_point}" if renderer.config.debug
                  line_to *(next_point.map { |p| p.send(renderer.units) })
                  last_point = next_point
                end
              end
            end
          end
          STDERR.puts 'Rendering END' if renderer.config.debug
        end
      end
    end
  end
end
