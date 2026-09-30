# frozen_string_literal: true

module Laser
  module Cutter
    # Note: this class badly needs refactoring and tests.  Both are coming.

    class Box
      # How the lid, the top panel, joins the walls: notched on all four sides,
      # on the side of the back wall only, or on none.
      LIDS = %i[full back plain].freeze

      # The side of each wall that meets the lid, as an index into Rect#sides.
      LID_SIDES = { 'front' => 0, 'left' => 0, 'right' => 0, 'back' => 2 }.freeze

      # Everything is in millimeters

      attr_accessor :dim, :thickness, :notch_width, :kerf, :padding, :units, :inside_box, :front, :back, :top, :bottom, :left, :right, :faces, :bounds, :conf, :corner_face, :metadata, :notches

      # @return [Symbol] one of LIDS
      attr_accessor :lid

      # @return [Hash{String => Array<Geometry::Line>}] the lines to cut for each face, by its name
      attr_accessor :outlines

      def initialize(config = {})
        self.dim = Geometry::Dimensions.new(config['width'], config['height'], config['depth'])
        self.thickness = config['thickness']

        self.notch_width = config['notch'] || (1.0 * longest / 5.0)
        self.kerf = config['kerf'] || 0.0
        self.padding = config['padding']
        self.units = config['units']
        self.inside_box = config['inside_box']
        self.lid = (config['lid'] || LIDS.first).to_sym

        self.notches = []
        self.outlines = {}

        self.metadata = Geometry::Point[config['metadata_width'] || 0, config['metadata_height'] || 0]

        create_faces! # generates dimensions for each side
        self.faces = [top, front, bottom, back, left, right]

        self.conf = {
          valign:  [:out, :out, :out, :out, :in, :in],
          halign:  [:in, :out, :in, :out, :in, :in],
          corners: {
            front: [:no, :yes, :no, :yes, :no, :no], # our default choice, but may not work
            top:   [:yes, :no, :yes, :no, :no, :no] # 2nd choice, has to work if 1st doesn't
          },
        }
      end

      def enclosure
        generate_notches if notches.empty?
        p1 = notches.first.p1.to_a
        p2 = notches.first.p2.to_a

        notches.each do |notch|
          n = notch.normalized
          n.p1.to_a.each_with_index { |c, i| p1[i] = c if c < p1[i] }
          n.p2.to_a.each_with_index { |c, i| p2[i] = c if c > p2[i] }
        end

        Geometry::Rect[Geometry::Point.new(p1), Geometry::Point.new(p2)]
      end

      def generate_notches
        position_faces!
        corner_face = pick_corners_face
        self.notches = []
        self.outlines = {}
        faces.each_with_index do |face, face_index|
          edges = edges_of(face, face_index, corner_face)

          if edges.any?(&:corners) && !edges.all?(&:first_notch_out?)
            edges.each { |e| e.adjust_corners = true }
          end

          outlines[face.name] = Aggregator.new(lines_of(face, edges)).lines
          notches << outlines[face.name]
        end
        notches.flatten!
      end

      def w; dim.w; end
      def h; dim.h; end
      def d; dim.d; end

      def longest
        [w, h, d].max
      end

      def to_s
        "Box:\nH:#{dim.h} W:#{dim.w} D:#{dim.d}\nThickness:#{thickness}, Notch:#{notch_width}"
      end

      private

      # One edge for each side of a face, pairing the side with the matching
      # side of the face grown by the thickness.
      #
      # @return [Array<Notching::Edge>]
      def edges_of(face, face_index, corner_face)
        bound = face_bounding_rect(face)
        bound.sides.each_with_index.map do |bounding_side, side_index|
          include_corners = conf[:corners][corner_face][face_index] == :yes && side_index.odd?
          key = side_index.odd? ? :valign : :halign
          Notching::Edge.new(bounding_side,
                             face.sides[side_index],
                             { notch_width: notch_width,
                               thickness:   thickness,
                               kerf:        kerf,
                               center_out:  conf[key][face_index] == :out,
                               corners:     include_corners,
                               corner_ends: corner_ends(face, side_index) })
        end
      end

      # A lid that lifts off covers the corners above the walls, so a wall
      # keeps no corner box at the end of a side that touches the lid.
      #
      # @return [Array<Integer>] the ends of the side that may carry a corner box
      def corner_ends(face, side_index)
        lid_side = LID_SIDES[face.name]
        return Notching::Edge::ENDS if lid == :full || lid_side.nil?

        case (side_index - lid_side) % 4
        when 1 then [2]
        when 3 then [1]
        else Notching::Edge::ENDS
        end
      end

      # @return [Array<Geometry::Line>] the lines of a face before they are merged
      def lines_of(face, edges)
        return lid_lines(edges) if face.equal?(top)

        edges.each_with_index.flat_map do |edge, side_index|
          straight?(face, side_index) ? [edge.inside] : Notching::PathGenerator.new(edge).generate
        end
      end

      # Whether a side of a wall lies under a lid edge that has no notches.
      def straight?(face, side_index)
        return false if lid == :full || (lid == :back && face.equal?(back))

        LID_SIDES[face.name] == side_index
      end

      def lid_lines(edges)
        case lid
        when :plain then edges.map(&:outside)
        when :back then back_lid_lines(edges)
        else edges.flat_map { |edge| Notching::PathGenerator.new(edge).generate }
        end
      end

      # The lid notched into the back wall only. Its other three edges are
      # straight, along the outside of the walls. Either side of the notches
      # it has a foot, the corner square above the side wall.
      def back_lid_lines(edges)
        joint = edges.first
        joint.corners = true
        joint.adjust_corners = true
        path = Notching::PathGenerator.new(joint).notch_lines

        path + foot(joint.outside.p1, path.first.p1) + foot(joint.outside.p2, path.last.p2) + edges.drop(1).map(&:outside)
      end

      # The two sides of a foot the notches do not draw: its bottom, from the
      # outer corner of the lid, and the side that faces the first notch.
      def foot(corner, notch)
        turn = Geometry::Point[notch.x, corner.y]
        [Geometry::Line[corner, turn], Geometry::Line[turn, notch]]
      end

      def face_bounding_rect(face)
        b = face.clone
        b.move_to(b.position.plus(-thickness, -thickness))
        b.p2 = b.p2.plus(2 * thickness, 2 * thickness)
        b.relocate!
      end

      # ___________________________________________________________________
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
      # ___________________________________________________________________

      def position_faces!
        offset_x = [padding + d + (3 * thickness), metadata.x + (2 * thickness) + padding].max
        offset_y = [padding + d + (3 * thickness), metadata.y + (2 * thickness) + padding].max

        # X Coordinate
        left.x  = offset_x - d - (2 * thickness) - padding
        right.x = offset_x + w + (2 * thickness) + padding

        [bottom, front, top, back].each { |s| s.x = offset_x }

        # Y Coordinate
        top.y    = offset_y - d - (2 * thickness) - padding
        bottom.y = offset_y + h + (2 * thickness) + padding
        back.y   = bottom.y + d + (2 * thickness) + padding

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
          edges << Notching::Edge.new(b.sides[index], face, notch_width: notch_width, kerf: kerf )
        end
        edges.map(&:notch_count).all?{ |c| c % 4 == 3 } ? :top : :front
      end
    end
  end
end
