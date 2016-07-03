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
          STDOUT.puts 'Layout: Rendering BEGIN'.blue.bold if config.debug

          renderer = self
          renderers = []

          box_renderer = BoxRenderer.new(config)
          renderers << box_renderer

          # noinspection RubyResolve
          if config.print_metadata
            meta_renderer = MetaRenderer.new(config)
            renderers << meta_renderer
            box_renderer.ensure_space_for(meta_renderer.enclosure)
          end

          if config.debug
            unkerfed_config = Laser::Cutter::Configuration.new(config.to_hash)
            unkerfed_config.merge!(kerf: 0.0, color: 'DD2211')
            unkerfed_box_renderer = BoxRenderer.new(unkerfed_config)
            unkerfed_box_renderer.ensure_space_for(meta_renderer.enclosure) if meta_renderer
            renderers << unkerfed_box_renderer
          end

          margin = config.margin.to_f.send(config.units.to_sym)
          page_size = config.page_size || calculate_image_boundary(box_renderer, margin)

          pdf = Prawn::Document.new(:margin => margin,
                                    :page_size => page_size,
                                    :page_layout => self.config.page_layout.to_sym)

          pdf.instance_eval do
            renderers.each {|r|  r.render(self) }
            render_file(renderer.config.file)
          end

          if config.verbose
            puts "PDF saved to #{config.file}."
          end
          STDERR.puts 'Layout: Rendering END'.bold.blue if config.debug

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
