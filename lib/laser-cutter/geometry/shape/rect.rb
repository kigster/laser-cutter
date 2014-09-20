module Laser
  module Cutter
    module Geometry
      class Rect < Shape
        attr_accessor :width, :height, :name

        def initialize(width, height, name = nil)
          self.width = width
          self.height = height
          self.name = name
        end

        def with_name value
          self.name = value
          self
        end

        def render pdf
          rect = self
          puts "Printing Rectangle: #{self}"
          pdf.line_width = 0.001.in
          pdf.stroke do
            pdf.rectangle [rect.position.x, rect.position.y + rect.height].map(&:mm), rect.width.mm, rect.height.mm
          end
        end

        def to_s
          "#{sprintf "%3d", width}(w)x#{sprintf "%3d", height}(h) @ #{position.to_s} #{name}"
        end

      end

    end

  end
end
