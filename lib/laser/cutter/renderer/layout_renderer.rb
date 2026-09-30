# frozen_string_literal: true

module Laser
  module Cutter
    module Renderer
      # Writes the PDF: the box, its metadata block, and the unkerfed outline
      # when asked for.
      class LayoutRenderer < Base
        UNKERFED_COLOR = 'DD2211'

        def initialize(config)
          self.config = config
          super
        end

        # @return [Integer] how many lines {#render} draws, and yields
        def total
          box_renderers.sum { |renderer| renderer.lines.size }
        end

        # Writes the file, yielding after each line drawn.
        def render(&)
          margin = config.margin.to_f.send(units)
          pdf = Prawn::Document.new(margin:      margin,
                                    page_size:   config.page_size || calculate_image_boundary(box_renderers.first, margin),
                                    page_layout: config.page_layout.to_sym)

          box_renderers.first.render(pdf, &)
          meta_renderer&.render(pdf)
          box_renderers.drop(1).each { |renderer| renderer.render(pdf, &) }
          pdf.render_file(config.file)
        end

        def calculate_image_boundary(box_renderer, margin)
          box_renderer.enclosure.to_a[1].map do |c|
            c.send(units) + (2 * margin)
          end
        end

        private

        def meta_renderer
          @meta_renderer ||= MetaRenderer.new(config) if config.metadata
        end

        # The box, then the same box without kerf when config.debug is set.
        def box_renderers
          @box_renderers ||= begin
            configs = [config]
            configs << Configuration.new(config.to_hash).merge!(kerf: 0.0, color: UNKERFED_COLOR) if config.debug
            configs.map do |box_config|
              BoxRenderer.new(box_config).tap do |renderer|
                renderer.ensure_space_for(meta_renderer.enclosure) if meta_renderer
              end
            end
          end
        end
      end
    end
  end
end
