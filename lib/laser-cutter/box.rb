module Laser
  module Cutter
    class Box
      # Everything is in millimeters

      attr_accessor :dim, :thick, :notch
      attr_accessor :margin, :padding

      attr_accessor :front, :back, :top, :bottom, :left, :right
      attr_accessor :sides

      def initialize(dimension, thick, notch = nil)
        self.dim = dimension if (dimension.is_a?(Dimension) && dimension.valid?)
        self.thick = thick
        self.notch = notch
        self.notch = (self.thick * 2) if self.notch.nil?
        self.margin = 2
        self.padding = 5

        self.front = Rect.new(dim.width, dim.height, "front")
        self.back = front.clone.with_name("back")

        self.top = Rect.new(dim.width, dim.depth, "top")
        self.bottom = top.clone.with_name("bottom")

        self.left = Rect.new(dim.depth, dim.height, "left")
        self.right = left.clone.with_name("right")

        self.sides = [top, front, bottom, back, left, right]

        layout_sides
        self
      end

      def layout_sides
        #
        #               +-----------------+
        #               |                 |
        #               | back:     W x H |
        #               |                 |
        #               +-----------------+
        #               +-----------------+
        #               | bottom:   W x D |
        #               +-----------------+
        #   +--------+  +-----------------+  +--------+
        #   |        |  |                 |  |        |
        #   | left   |  | front:    W x H |  | right  |
        #   | D x H  |  |                 |  | D x H  |
        #   +--------+  +-----------------+  +--------+
        #               +-----------------+
        #               | top:      W x D |
        #               +-----------------+
        #
        # 0,0
        #___________________________________________________________________


        # Deal with X
        group_shift = margin + depth + padding
        [top, front, bottom, back].each{|s| s.position.x = group_shift }
        left.position.x = margin
        right.position.x = margin + 2 * padding + width + depth

        # Deal with Y
        top.position.y = margin
        group_shift = margin + depth + padding
        [left, front, right].each{ |s| s.position.y = group_shift }
        bottom.position.y = margin + depth + 2 * padding + height
        back.position.y = margin + 3 * padding + 2 * depth + height
      end

      def width
        dim.width
      end

      def height
        dim.height
      end

      def depth
        dim.depth
      end

      def render
        pdf = Prawn::Document.new(:page_size => "LETTER", :page_layout => :portrait)
        pdf.text "Laser Cutter, version #{Laser::Cutter::VERSION}"
        pdf.text "#{self.to_s}"
        pdf.stroke_axis
        sides.each do |rect|
          rect.render(pdf)
        end
        pdf.render_file "output.pdf"
      end

      def to_s
        "Box Parameters:\nH:#{dim.height} W:#{dim.width} D:#{dim.depth}\nThickness:#{thick}, Notch:#{notch}"
      end
    end
  end
end
