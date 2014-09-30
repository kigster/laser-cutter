# encoding: utf-8
require 'json'
module Laser
  module Cutter
    module Renderer
      class LayoutRenderer < Base
        def initialize(config)
          self.config = config
        end

        def render
          renderer = self

          meta_renderer = MetaRenderer.new(config)
          box_renderer = BoxRenderer.new(config)
          box_renderer.ensure_space_for(meta_renderer.enclosure) if config.metadata

          page_size = config.page_size || 'LETTER' # TODO: auto-detect page size based on box dimensions.

          pdf = Prawn::Document.new(:margin => config.margin.to_f.send(config.units.to_sym),
                                    :page_size => page_size,
                                    :page_layout => config.page_layout.to_sym)

          pdf.instance_eval do
            if renderer.config.metadata
              meta_renderer.render(self)
            end
            box_renderer.render(self)
            render_file(renderer.config.file)
          end

          if config.verbose
            puts "PDF saved to #{config.file}."
          end
        end

      end
    end
  end
end
