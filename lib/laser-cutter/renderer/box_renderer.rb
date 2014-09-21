require 'json'
module Laser
  module Cutter
    module Renderer
      class BoxRenderer < AbstractRenderer

        def box
          subject
        end

        def render pdf = nil
          pdf = Prawn::Document.new(:page_size => options.page_size, :page_layout => options.page_layout.to_sym)

          header = <<-EOF
Made with love, using Laser Cutter Ruby Gem (v#{Laser::Cutter::VERSION})
Credits to Prawn PDF gem and BoxMaker for inspiration.

https://github.com/kigster/laser-cutter
          EOF
          pdf.float do
            pdf.bounding_box([0, 700], :width => 200, :height => 100) do
              pdf.font('Helvetica', :size => 6) do
                pdf.text header, :color => "0050FF"
              end
            end
            pdf.bounding_box([400, 710], :width => 200, :height => 300) do
              pdf.font('Courier', :size => 6) do
                pdf.text JSON.pretty_generate(options.to_hash), :color => "222222"
              end
            end
          end

          pdf.line_width = options.stroke.send(options.units.to_sym)
          pdf.stroke_color "000000"
          box.notches.each do |notch|
            LineRenderer.new(notch, options).render(pdf)
          end

          pdf.render_file(options.file)
          if options.verbose
            puts "File #{options.file} created."
          end
        end

      end
    end
  end
end
