require 'forwardable'
module Laser
  module Cutter
    class Box
      # Everything is in millimeters
      extend Forwardable
      def_delegators :@dim, :w, :h, :d

      attr_accessor :dim, :thickness, :notch_width, :kerf
      attr_accessor :padding, :units, :inside_box, :computed_notch_widths

      attr_accessor :front, :back, :top, :bottom, :left, :right
      attr_accessor :faces, :bounds, :conf, :corner_face
      attr_accessor :metadata, :notches

      def initialize(config = {})
        @dim         = Geometry::Dimensions.new(config['width'], config['height'], config['depth'])
        @thickness   = config['thickness']
        @notch_width = config['notch'] || (1.0 * longest / 5.0)
        @kerf        = config['kerf'] || 0.0
        @padding     = config['padding']
        @units       = config['units']
        @inside_box  = config['inside_box']

        @computed_notch_widths = { w: nil, h: nil, d: nil }

        @notches = []
        @conf    = {
          valign:  [:out, :out, :out, :out, :in, :in],
          halign:  [:in, :out, :in, :out, :in, :in],
          corners: {
            top: [:yes, :no, :yes, :no, :no, :no], # 2nd choice, has to work if 1st doesn't
            front: [:no, :yes, :no, :yes, :no, :no], # our default choice, but may not work
          },
        }

        @metadata = Geometry::Point[config['metadata_width'] || 0, config['metadata_height'] || 0]
        create_faces! # generates dimensions for each side
      end

      def generate_notches
        position_faces!
        @corner_face = pick_corners_face
        @notches     = []
        faces.each_with_index do |face, face_index|
          create_face_edges(face, face_index)
        end
        @notches.flatten!
      end

      def enclosure
        generate_notches if notches.empty?
        p1 = notches.first.p1.to_a
        p2 = notches.first.p2.to_a

        notches.each do |notch|
          n = notch.normalized
          n.p1.to_a.each_with_index {|c, i| p1[i] = c if c < p1[i]}
          n.p2.to_a.each_with_index {|c, i| p2[i] = c if c > p2[i]}
        end

        Geometry::Rect[Geometry::Point.new(p1), Geometry::Point.new(p2)]
      end

      def longest
        [w, h, d].max
      end

      def to_s
        "Box:\nH:#{dim.h} W:#{dim.w} D:#{dim.d}\nThickness:#{thickness}, Notch:#{notch_width}"
      end

      private

      def create_face_edges(face, face_index)
        edges = create_bound_edges(face, face_index)
        if edges.any? {|e| e.corners} && !edges.all? {|e| e.first_notch_out?}
          edges.each {|e| e.adjust_corners = true}
        end
        convert_to_lines(edges)
      end

      def convert_to_lines(edges)
        side_lines = []

        edges.each {|edge| side_lines << Notching::PathGenerator.new(edge).generate}

        agg = Aggregator.new(side_lines.flatten)
        agg.dedup!.deoverlap!.dedup!
        @notches << agg.lines.flatten.map(&:normalized).uniq
      end

      def create_bound_edges(face, face_index)
        bounding_rect = face_bounding_rect(face)
        edges         = []
        bounding_rect.sides.each_with_index do |bounding_side, side_index|
          center_out, include_corners = configure(face_index, side_index)
          edges << Notching::Edge.new(
            bounding_side,
            face.sides[side_index],
            { :notch_width           => notch_width,
              :thickness             => thickness,
              :kerf                  => kerf,
              :center_out            => center_out,
              :corners               => include_corners,
              :dimension             => edge_dimension(face, side_index),
              :computed_notch_widths => computed_notch_widths
            })
        end
        edges
      end

      def configure(face_index, side_index)
        include_corners = (conf[:corners][corner_face][face_index] == :yes && side_index.odd?)
        key             = side_index.odd? ? :valign : :halign
        center_out      = (conf[key][face_index] == :out)
        return center_out, include_corners
      end

      def edge_dimension(face, side_index)
        dim_idx = side_index % 2
        face_dimension_mapping[face.name][dim_idx]
      end

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

        [bottom, front, top, back].each {|s| s.x = offset_x}

        # Y Coordinate
        top.y    = offset_y - d - 2 * thickness - padding
        bottom.y = offset_y + h + 2 * thickness + padding
        back.y   = bottom.y + d + 2 * thickness + padding

        [left, front, right].each {|s| s.y = offset_y}

        faces.each(&:relocate!)
      end

      def create_faces!
        zero = Geometry::Point.new(0, 0)

        @front  = Geometry::Rect.create(zero, dim.w, dim.h, "front")
        @back   = Geometry::Rect.create(zero, dim.w, dim.h, "back")
        @top    = Geometry::Rect.create(zero, dim.w, dim.d, "top")
        @bottom = Geometry::Rect.create(zero, dim.w, dim.d, "bottom")
        @left   = Geometry::Rect.create(zero, dim.d, dim.h, "left")
        @right  = Geometry::Rect.create(zero, dim.d, dim.h, "right")

        @faces = [top, front, bottom, back, left, right]
      end

      def face_dimension_mapping
        @mapping ||= {
          'front'  => [:w, :h],
          'back'   => [:w, :h],
          'top'    => [:w, :d],
          'bottom' => [:w, :d],
          'left'   => [:d, :h],
          'right'  => [:d, :h]
        }
      end

      # Choose which face will be responsible for filling out the little square overlap
      # in the corners. Only one of the 3 possible sides need to be picked.
      def pick_corners_face
        b     = face_bounding_rect(front)
        edges = []
        front.sides[0..1].each_with_index do |face, index|
          edges << Notching::Edge.new(b.sides[index], face, :notch_width => notch_width, :kerf => kerf)
        end
        edges.map(&:notch_count).all? {|c| c % 4 == 3} ? :top : :front
      end

    end
  end
end
