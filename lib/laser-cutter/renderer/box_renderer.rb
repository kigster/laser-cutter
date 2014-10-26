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
          coords = [ rect.p2.x, rect.p2.y ].map{|a| page_manager.value_from_units(a)}
          box.metadata = Geometry::Point.new(coords)
        end

        def enclosure
          box.enclosure
        end

        def render pdf = nil
          renderer = self
          pdf.instance_eval do
            self.line_width = renderer.config.stroke.send(renderer.config.units.to_sym)
            stroke_color BLACK
            renderer.box.generate_notches.each do |notch|
              LineRenderer.new(renderer.config, notch).render(self)
            end
          end
        end
      end
    end
  end
end
