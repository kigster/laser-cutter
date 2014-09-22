module Laser
  module Cutter
    class Box
      # Everything is in millimeters

      attr_accessor :dim, :thickness, :notch_width
      attr_accessor :padding, :units

      attr_accessor :front, :back, :top, :bottom, :left, :right
      attr_accessor :faces, :bounds, :conf

      def initialize(config = {})
        self.dim = Geometry::Dimensions.new(config['width'], config['height'], config['depth'])
        self.thickness = config['thickness']

        self.notch_width = config['notch'] || (1.0 * self.longest / 5.0)
        self.padding = config['padding']
        self.units = config['units']

        create_faces! # generates dimensions for each side
        self.faces = [top, front, bottom, back, left, right]

        position_faces!
        self.conf   = {
            valign: [ :out, :out,  :out,  :out, :in, :in],
            halign: [ :in,  :out,  :in,   :out, :in, :in],
            corners:[ :no,  :yes,  :no,   :yes, :no, :no]
        }

        self
      end

      # Returns an flattened array of lines representing notched
      # rectangle.
      def notches
        generate_bounding_boxes!

        notches = []

        faces.each_with_index do |face, face_index|
          bound = bounds[face_index]
          bound.sides.each_with_index do |bounding_side, side_index |
            key = side_index.odd? ? :valign : :halign
            path = Geometry::PathGenerator.new(:notch_width => notch_width,
                                               :center_out => (self.conf[key][face_index] == :out) ,
                                               :fill_corners => (self.conf[:corners][face_index] == :yes && side_index.odd?),
                                               :thickness => thickness
            ).path(Geometry::Edge.new(bounding_side, face.sides[side_index], self.notch_width))
            notches << path.create_lines
          end
        end

        Geometry::PathGenerator.deduplicate(notches.flatten.sort)
      end

      def w; dim.w; end
      def h; dim.h; end
      def d; dim.d; end

      def longest
        [w, h, d].max()
      end

      def to_s
        "Box:\nH:#{dim.h} W:#{dim.w} D:#{dim.d}\nThickness:#{thickness}, Notch:#{notch_width}"
      end

      private

      def generate_bounding_boxes!
        self.bounds = []
        self.bounds = faces.map do |face|
          b = face.clone
          b.move_to(b.position.move_by(-thickness, -thickness))
          b.p2 = b.p2.move_by(2 * thickness, 2 * thickness)
          b.relocate!
          b
        end
      end

      #___________________________________________________________________
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

      def position_faces!
        offset = padding + d + 3 * thickness
        left.x = top.y = thickness
        [bottom, front, top, back].each do |s|
          s.x = offset
        end

        right.x = 2 * padding + w + d + 5 * thickness
        [left, front, right].each do |s|
          s.y = offset
        end

        bottom.y = d + 2 * padding + h + 5 * thickness
        back.y = 3 * padding + 2 * d + h + 7*thickness

        faces.each(&:relocate!)

      end

      def create_faces!
        zero = Geometry::Point.new(0, 0)
        self.front = Geometry::Rect.create(zero, dim.w, dim.h, "front")
        self.back = Geometry::Rect.create(zero, dim.w, dim.h, "back")

        self.top = Geometry::Rect.create(zero, dim.w, dim.d, "top")
        self.bottom = Geometry::Rect.create(zero, dim.w, dim.d, "bottom")

        self.left = Geometry::Rect.create(zero, dim.d, dim.h, "left")
        self.right = Geometry::Rect.create(zero, dim.d, dim.h, "right")
      end

    end
  end
end
