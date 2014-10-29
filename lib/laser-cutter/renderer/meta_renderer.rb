# encoding: utf-8
class Laser::Cutter::Renderer::MetaRenderer < Laser::Cutter::Renderer::Base

  META_KEYS = %w(units width height depth thickness notch kerf stroke padding margin page_size page_layout)

  def initialize(config = {})
    self.config = config
    self.enclosure = Laser::Cutter::Geometry::Rect.create(Laser::Cutter::Geometry::Point[1, 1], 140, 150)
  end

  def render pdf = nil
    banner = <<-EOF

    Made with Laser Cutter Ruby Gem (v#{Laser::Cutter::VERSION})
    Credits to Prawn for ruby PDF generation,
    and BoxMaker for inspiration.

    Online: http://makeabox.io/
    Source: https://github.com/kigster/laser-cutter
    EOF

    meta_color = BLUE
    meta_top_height = 55

    metadata = config.to_hash
    metadata['page_size'] ||= 'custom'
    metadata.delete('page_layout') if metadata['page_size'].eql?('custom')

    meta_fields = META_KEYS.find_all{|k| metadata[k]}.join(": \n") + ": \n"
    meta_values = META_KEYS.find_all{|k| metadata[k]}.map{|k| metadata[k] }.join("\n")

    rect = self.enclosure

    pdf.instance_eval do
      self.line_width = 0.2.mm
      float do
        bounding_box([rect.p1.x, rect.h + rect.p1.y], :width => rect.w, :height => rect.h) do
          stroke_color meta_color
          stroke_bounds

          # Print banner
          indent 10 do
            font('Helvetica', :size => 6) do
              text banner, :color => meta_color
            end
          end

          # print values of the config, in two parts – keys right aligned first, values left aligned second.
          float do
            bounding_box([0, rect.h - meta_top_height],
                         :width => rect.w,
                         :height => rect.h - meta_top_height) do
              float do
                bounding_box([0, rect.h - meta_top_height], :width => 70, :height => rect.h - meta_top_height) do
                  indent 10 do
                    font('Helvetica', :size => 7) do
                      text meta_fields, :color => meta_color, align: :right
                    end
                  end
                end
              end
              float do
                bounding_box([60, rect.h - meta_top_height], :width => 70, :height => rect.h - meta_top_height) do
                  indent 10 do
                    font('Helvetica', :size => 7) do
                      text meta_values, :color => meta_color
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
