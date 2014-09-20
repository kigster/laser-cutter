module Laser
  module Cutter
    module Renderer
      class BoxRenderer < AbstractRenderer
        def box
          subject
        end
        def render pdf = nil
          pdf = Prawn::Document.new(:page_size => "LETTER", :page_layout => :portrait)
          pdf.text "Laser Cutter, version #{Laser::Cutter::VERSION}"
          pdf.text "#{box.to_s}"
          pdf.line_width = 0.001.in
          pdf.stroke_color "000000"
          pdf.stroke_axis
          box.faces.each do |rect|
            #RectRenderer.new(rect).render(pdf)
          end
          box.bounds.each do |rect|
            #RectRenderer.new(rect).render(pdf)
          end

          box.notches.each do |notch|
            LineRenderer.new(notch).render(pdf)
          end
          pdf.render_file "output.pdf"
        end

      end
    end
  end
end
