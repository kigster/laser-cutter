module Laser
  module Cutter
    class Box
      # Everything is in millimeters

      attr_accessor :dim, :thickness, :notch_width
      attr_accessor :margin, :padding

      attr_accessor :front, :back, :top, :bottom, :left, :right
      attr_accessor :faces, :bounds, :notches, :conf

      def initialize(dimension, thickness, notch_width = nil)
        self.dim = dimension if (dimension.is_a?(Geometry::Dimensions) && dimension.valid?)
        self.thickness = thickness
        self.notch_width = notch_width || (1.0 * self.longest / 5.0)
        self.margin = 5
        self.padding = 3

        zero = Geometry::Point.new(0,0)

        self.front  = Geometry::Rect.create(zero, dim.w, dim.h, "front")
        self.back   = Geometry::Rect.create(zero, dim.w, dim.h, "back")

        self.top    = Geometry::Rect.create(zero, dim.w, dim.d, "top")
        self.bottom = Geometry::Rect.create(zero, dim.w, dim.d, "bottom")

        self.left   = Geometry::Rect.create(zero, dim.d, dim.h, "left")
        self.right  = Geometry::Rect.create(zero, dim.d, dim.h, "right")

        self.faces  = [top, front, bottom, back, left, right]
        self.conf   = {
            valign: [ :out, :out,  :out,  :out, :in, :in],
            halign: [ :in,  :out,  :in,   :out, :in, :in],
            corners:[ :no,  :yes,  :no,   :yes, :no, :no]
        }
        self.bounds = []

        layout_faces
        self
      end

      def layout_faces
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
        #               | top   :   W x D |
        #               +-----------------+
        #
        # 0,0
        #___________________________________________________________________


        offset = margin + padding + d + 3 * thickness

        left.x = top.y = margin + thickness

        [bottom, front, top, back].each do |s|
          s.x = offset
        end

        right.x = margin + 2 * padding + w + d + 5 * thickness

        [left, front, right].each do |s|
          s.y = offset
        end

        bottom.y = margin + d + 2 * padding + h + 5 * thickness
        back.y = margin + 3 * padding + 2 * d + h + 7*thickness

        faces.each(&:relocate!)
        self.bounds = faces.map do |face|
          b = face.clone
          b.move_to(b.position.move_by(-thickness, -thickness))
          b.p2 = b.p2.move_by(2 * thickness, 2 * thickness)
          b.relocate!
          b
        end

        notch_up!
      end


      def notch_up!
        self.notches = []

        faces.each_with_index do |face, index|
          bound = bounds[index]
          bound.sides.each_with_index do |bounding_side, subindex |
            key = subindex.odd? ? :valign : :halign
            path = Geometry::PathGenerator.new(:notch_width => notch_width,
                                               :center_out => (self.conf[key][index] == :out) ,
                                               :fill_corner => false,
                                               :thickness => thickness
            ).path(Geometry::Edge.new(bounding_side, face.sides[subindex], self.notch_width))

            self.notches << path.create_lines
          end
        end
        self.notches.flatten!
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

      def longest
        [w, h, d].max()
      end


      def to_s
        "Box Parameters:\nH:#{dim.h} W:#{dim.w} D:#{dim.d}\nThickness:#{thickness}, Notch:#{notch_width}"
      end
    end
  end
end
