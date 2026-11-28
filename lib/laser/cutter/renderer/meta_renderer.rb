# frozen_string_literal: true

module Laser
  module Cutter
    module Renderer
      class MetaRenderer < Laser::Cutter::Renderer::Base
        META_KEYS = %i(units width height depth front_height slope thickness notch lid kerf stroke padding margin page_size page_layout).freeze

        # The block, in points: its width, the height of the banner above the
        # settings, the height of one line of them, and the space under the last.
        WIDTH = 140
        BANNER_HEIGHT = 55
        LINE_HEIGHT = 8.2
        FOOTER_HEIGHT = 4

        def initialize(config = {})
          self.config = config
          height = BANNER_HEIGHT + (fields.size * LINE_HEIGHT) + FOOTER_HEIGHT
          self.enclosure = Laser::Cutter::Geometry::Rect.create(Laser::Cutter::Geometry::Point[1, 1], WIDTH, height)
        end

        # The settings the block prints, in order. The block is as tall as
        # they need: one line too many would start a second page.
        #
        # @return [Hash{Symbol => Object}]
        def fields
          metadata = config.to_hash
          metadata[:page_size] ||= 'custom'
          metadata.delete(:page_layout) if metadata[:page_size].eql?('custom')
          META_KEYS.select { |key| metadata[key] }.to_h { |key| [key, metadata[key]] }
        end

        def render(pdf = nil)
          banner = <<-EOF

    Made with Laser Cutter Ruby Gem (v#{Laser::Cutter::VERSION})
    Credits to Prawn for ruby PDF generation,
    and BoxMaker for inspiration.

    Online: http://makeabox.io/
    Source: https://github.com/kigster/laser-cutter
          EOF

          meta_color = BLUE
          meta_top_height = BANNER_HEIGHT

          meta_fields = fields.keys.join(": \n") + ": \n"
          meta_values = fields.values.join("\n")

          rect = enclosure

          pdf.instance_eval do
            self.line_width = 0.2.mm
            float do
              bounding_box([rect.p1.x, rect.h + rect.p1.y], width: rect.w, height: rect.h) do
                stroke_color meta_color
                stroke_bounds

                # Print banner
                indent 10 do
                  font('Helvetica', size: 6) do
                    text banner, color: meta_color
                  end
                end

                # print values of the config, in two parts – keys right aligned first, values left aligned second.
                float do
                  bounding_box([0, rect.h - meta_top_height],
                               width:  rect.w,
                               height: rect.h - meta_top_height) do
                    float do
                      bounding_box([0, rect.h - meta_top_height], width: 70, height: rect.h - meta_top_height) do
                        indent 10 do
                          font('Helvetica', size: 7) do
                            text meta_fields, color: meta_color, align: :right
                          end
                        end
                      end
                    end
                    float do
                      bounding_box([60, rect.h - meta_top_height], width: 70, height: rect.h - meta_top_height) do
                        indent 10 do
                          font('Helvetica', size: 7) do
                            text meta_values, color: meta_color
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
