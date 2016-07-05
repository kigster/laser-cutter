# encoding: utf-8
require 'laser-cutter/helpers/colors'

class Laser::Cutter::Renderer::MetaRenderer < Laser::Cutter::Renderer::BaseRenderer

  META_KEYS = %w(units width height depth thickness notch kerf stroke padding margin page_size page_layout)

  def initialize(config = {})
    self.config    = config
    self.enclosure = Laser::Cutter::Geometry::Rect.create(Laser::Cutter::Geometry::Point[1, 1], 140, 150)
  end

  def render(pdf = nil)
    banner = <<-EOF
    Made with love and the Laser-Cutter (v#{Laser::Cutter::VERSION})
    Credits to Prawn PDF (v#{Prawn::VERSION}) for PDF/Ruby.

    Make boxes online           ➩   http://makeabox.io/
    Make boxes on command line  ➩   gem install laser-cutter; laser-cutter --help
    Contribute to the source    ➩   https://github.com/kigster/laser-cutter
    EOF

    color      = Hashie::Mash.new(
      border: color(:aliceblue),
      text:   {
        title:  color(:coral),
        fields: color(:darkmagenta),
        values: color(:darkgreen)
      }
    )

    meta_top_height = 55

    metadata             = config.to_hash
    metadata[:page_size] ||= 'custom'
    metadata.delete(:page_layout) if metadata[:page_size].eql?('custom')

    meta_fields = META_KEYS.find_all { |k| metadata[k] }.join(": \n") + ": \n"
    meta_values = META_KEYS.find_all { |k| metadata[k] }.map { |k| metadata[k] }.join("\n")

    rect = self.enclosure

    pdf.instance_eval do
      self.line_width = 0.2.mm
      float do
        bounding_box([rect.p1.x, rect.h + rect.p1.y], :width => rect.w, :height => rect.h) do
          stroke_color color.border
          stroke_bounds

          # Print banner
          indent 10 do
            font('Helvetica', :size => 6) do
              text banner, :color => color.text[:title]
            end
          end


          # print values of the config, in two parts – keys right aligned first, values left aligned second.
          float do
            bounding_box([0, rect.h - meta_top_height],
                         :width  => rect.w,
                         :height => rect.h - meta_top_height) do

              float do
                bounding_box([0, rect.h - meta_top_height], :width => 70, :height => rect.h - meta_top_height) do
                  indent 10 do
                    font('Helvetica', :size => 7) do
                      text meta_fields, :color => color.text[:fields], align: :right
                    end
                  end
                end
              end
              float do
                bounding_box([60, rect.h - meta_top_height], :width => 70, :height => rect.h - meta_top_height) do
                  indent 10 do
                    font('Helvetica', :size => 7) do
                      text meta_values, :color => color.text[:values]
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
