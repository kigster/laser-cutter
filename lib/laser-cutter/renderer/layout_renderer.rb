# encoding: utf-8
require 'json'
module Laser
  module Cutter
    module Renderer
      class LayoutRenderer < Base
        def initialize(config)
          self.config = config
          super(config)
        end

        def render
          renderer = self

          margin = config.margin.to_f.send(config.units.to_sym)
          meta_renderer = MetaRenderer.new(config)
          box_renderer1 = BoxRenderer.new(config)
          c2 = config.clone
          c2.merge!(:kerf => nil, :color => "DD2200")
          box_renderer2 = BoxRenderer.new(c2)

          box_renderer1.ensure_space_for(meta_renderer.enclosure) if config.metadata

          page_size = config.page_size || calculate_image_boundary(box_renderer1, margin)

          pdf = Prawn::Document.new(:margin => margin,
                                    :page_size => page_size,
                                    :page_layout => self.config.page_layout.to_sym)

          pdf.instance_eval do
            meta_renderer.render(self) if renderer.config.metadata
            box_renderer1.render(self)
            box_renderer2.render(self)
            render_file(renderer.config.file)
          end

          if config.verbose
            puts "PDF saved to #{config.file}."
          end
        end

        def calculate_image_boundary(box_renderer, margin)
          box_renderer.enclosure.to_a[1].map do |c|
            c.send(config.units.to_sym) + 2 * margin
          end
        end

      end
    end
  end
end
