# encoding: utf-8
require 'json'
module Laser
  module Cutter
    module Renderer
      class BoxRenderer < Base
        alias_method :box, :subject

        META_RECT = Geometry::Rect.create(Geometry::Point[2, 2], 140, 150)

        def initialize(config = {})
          self.config = config
          self.subject = Laser::Cutter::Box.new(config)
        end

        def ensure_space_for(rect)
          coords = [ META_RECT.p2.x, META_RECT.p2.y ].map{|a| config.value_from_units(a)}
          box.metadata = Geometry::Point.new(coords)
        end

        def render pdf = nil
          renderer = self
          pdf.instance_eval do
            self.line_width = renderer.config.stroke.send(renderer.config.units.to_sym)
            stroke_color BLACK
            renderer.box.notches.each do |notch|
              LineRenderer.new(renderer.config, notch).render(self)
            end
          end
        end
      end
    end
  end
end
