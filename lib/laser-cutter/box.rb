module Laser
  module Cutter
    class Box
      # Everything is in millimeters

      attr_accessor :dim, :thick, :notch
      attr_accessor :margin, :padding

      attr_accessor :front, :back, :top, :bottom, :left, :right
      attr_accessor :sides

      def initialize(dimension, thick, notch = nil)
        self.dim = dimension if (dimension.is_a?(Geometry::Dimensions) && dimension.valid?)
        self.thick = thick
        self.notch = notch
        self.notch = (self.thick * 2) if self.notch.nil?
        self.margin = 2
        self.padding = 5

        zero = Geometry::Point.new(0,0)

        self.front  = Geometry::Rect.new(zero, dim.w, dim.h, "front")
        self.back   = Geometry::Rect.new(zero, dim.w, dim.h, "back")

        self.top    = Geometry::Rect.new(zero, dim.w, dim.d, "top")
        self.bottom = Geometry::Rect.new(zero, dim.w, dim.d, "bottom")

        self.left   = Geometry::Rect.new(zero, dim.d, dim.h, "left")
        self.right  = Geometry::Rect.new(zero, dim.d, dim.h, "right")

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
        #               | top:      W x D |
        #               +-----------------+
        #   +--------+  +-----------------+  +--------+
        #   |        |  |                 |  |        |
        #   | left   |  | front:    W x H |  | right  |
        #   | D x H  |  |                 |  | D x H  |
        #   +--------+  +-----------------+  +--------+
        #               +-----------------+
        #               | bottom:   W x D |
        #               +-----------------+
        #
        # 0,0
        #___________________________________________________________________


        offset = margin + padding + d

        left.x = top.y = margin

        [bottom, front, top, back].each do |s|
          s.x = offset
        end

        right.x = margin + 2 * padding + w + d

        [left, front, right].each do |s|
          s.y = offset
        end

        bottom.y = margin + d + 2 * padding + h
        back.y = margin + 3 * padding + 2 * d + h

        sides.each(&:relocate!)
      end

      def w
        dim.w
      end

      def h
        dim.h
      end

      def d
        dim.d
      end


      def to_s
        "Box Parameters:\nH:#{dim.h} W:#{dim.w} D:#{dim.d}\nThickness:#{thick}, Notch:#{notch}"
      end
    end
  end
end
