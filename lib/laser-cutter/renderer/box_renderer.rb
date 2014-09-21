module Laser
  module Cutter
    module Renderer
      class BoxRenderer < AbstractRenderer
        def box
          subject
        end

        def render pdf = nil, filename = nil
          pdf = Prawn::Document.new(:page_size => "LETTER", :page_layout => :portrait)

          header = <<-EOF
Made with love, using Laser Cutter Ruby Gem (v#{Laser::Cutter::VERSION})
Credits to Prawn PDF gem and BoxMaker for inspiration.

https://github.com/kigster/laser-cutter
          EOF
          pdf.float do
            pdf.bounding_box([0, 700], :width => 300, :height => 100) do
              pdf.font('Helvetica', :size => 7) do
                pdf.text header, :color => "0080FF"
              end
            end
          end
          # pdf.text_box header, :at => [0, 700],
          #  :width => 250, :height => 50,
          #  :overflow => :shrink_to_fit,
          #  :min_font_size => 5, :color => "FF0000"


          pdf.line_width = 0.001.in
          pdf.stroke_color "FF8080"
          box.faces.each do |rect|
            #RectRenderer.new(rect).render(pdf)
          end
          pdf.stroke_color "80FF80"
          box.bounds.each do |rect|
            #RectRenderer.new(rect).render(pdf)
          end

          pdf.stroke_color "000080"
          box.notches.each do |notch|
            LineRenderer.new(notch).render(pdf)
          end
          pdf.render_file filename || "output.pdf"
        end

      end
    end
  end
end
