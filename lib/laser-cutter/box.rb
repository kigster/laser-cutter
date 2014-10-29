module Laser
  module Cutter
    # Note: this class badly needs refactoring and tests.  Both are coming.

    class Box
      # Everything is in millimeters

      attr_accessor :dim, :thickness, :notch_width, :kerf
      attr_accessor :padding, :units, :inside_box

      attr_accessor :front, :back, :top, :bottom, :left, :right
      attr_accessor :faces, :bounds, :conf, :corner_face
      attr_accessor :metadata, :notches

      def initialize(config = {})
        self.dim = Geometry::Dimensions.new(config['width'], config['height'], config['depth'])
        self.thickness = config['thickness']

        self.notch_width = config['notch'] || (1.0 * self.longest / 5.0)
        self.kerf = config['kerf'] || 0.0
        self.padding = config['padding']
        self.units = config['units']
        self.inside_box = config['inside_box']

        self.notches = []

        self.metadata = Geometry::Point[config['metadata_width'] || 0, config['metadata_height'] || 0]

        create_faces! # generates dimensions for each side
        self.faces =     [top, front, bottom, back, left, right]

        self.conf   = {
            valign: [    :out, :out,  :out,   :out, :in, :in],
            halign: [    :in,  :out,  :in,    :out, :in, :in],
            corners: {
                front: [ :no,  :yes,  :no,    :yes, :no, :no], # our default choice, but may not work
                top:   [ :yes, :no,   :yes,   :no,  :no, :no]  # 2nd choice, has to work if 1st doesn't
            },
        }
        self
      end

      def enclosure
        generate_notches if self.notches.empty?
        p1 = notches.first.p1.to_a
        p2 = notches.first.p2.to_a

        notches.each do |notch|
          n = notch.normalized
          n.p1.to_a.each_with_index {|c, i| p1[i] = c if c < p1[i] }
          n.p2.to_a.each_with_index {|c, i| p2[i] = c if c > p2[i] }
        end

        Geometry::Rect[Geometry::Point.new(p1), Geometry::Point.new(p2)]
      end

      def generate_notches
        position_faces!
        corner_face = pick_corners_face
        self.notches = []
        faces.each_with_index do |face, face_index|
          bound = face_bounding_rect(face)
          side_lines = []
          bound.sides.each_with_index do |bounding_side, side_index |
            include_corners = (self.conf[:corners][corner_face][face_index] == :yes && side_index.odd?)
            key = side_index.odd? ? :valign : :halign
            center_out = (self.conf[key][face_index] == :out)
            edge = Notching::Edge.new(bounding_side, face.sides[side_index],
                            {:notch_width => notch_width,
                             :thickness => thickness,
                             :kerf => kerf,
                             :center_out => center_out,
                             :corners => include_corners
                            })
            path = Notching::PathGenerator.new(edge).generate
            side_lines << path.create_lines
            # side_lines << bounding_side
            # side_lines << face.sides[side_index]
          end
          aggregator = Aggregator.new(side_lines.flatten)
          aggregator.dedup!.deoverlap!.dedup!
          self.notches << aggregator.lines
        end
        self.notches.flatten!
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

      def face_bounding_rect(face)
        b = face.clone
        b.move_to(b.position.plus(-thickness, -thickness))
        b.p2 = b.p2.plus(2 * thickness, 2 * thickness)
        b.relocate!
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
      #   +--------+  X-----------------+  +--------+
      #               +-----------------+
      #               | top   :   W x D |
      #               +-----------------+
      #
      # 0,0
      #___________________________________________________________________

      def position_faces!
        offset_x = [padding + d + 3 * thickness, metadata.x + 2 * thickness + padding].max
        offset_y = [padding + d + 3 * thickness, metadata.y + 2 * thickness + padding].max

        # X Coordinate
        left.x  = offset_x - d - 2 * thickness - padding
        right.x = offset_x + w + 2 * thickness + padding

        [bottom, front, top, back].each { |s| s.x = offset_x }

        # Y Coordinate
        top.y    = offset_y - d - 2 * thickness - padding
        bottom.y = offset_y + h + 2 * thickness + padding
        back.y   = bottom.y + d + 2 * thickness + padding

        [left, front, right].each { |s| s.y = offset_y }

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

      # Choose which face will be responsible for filling out the little square overlap
      # in the corners. Only one of the 3 possible sides need to be picked.
      def pick_corners_face
        b = face_bounding_rect(front)
        edges = []
        front.sides[0..1].each_with_index do |face, index|
          edges << Notching::Edge.new(b.sides[index], face, :notch_width => notch_width )
        end
        edges.map(&:notch_count).all?{|c| c % 4 == 3} ? :top : :front
      end

    end
  end
end
