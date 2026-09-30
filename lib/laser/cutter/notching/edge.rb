# frozen_string_literal: true

module Laser
  module Cutter
    module Notching
      MINIMUM_NOTCHES_PER_SIDE = 3
      # Decimal places kept of length / notch width before counting notches.
      RATIO_DIGITS = 6
      # This class represents a single edge of one side: both inside
      # and outside edge of the material.  It's also responsible
      # for calculating the "perfect" notch width.
      class Edge
        # Both ends of an edge: 1 for p1, 2 for p2.
        ENDS = [1, 2].freeze

        attr_accessor :outside, :inside, :notch_width, :thickness, :kerf, :center_out, :corners, :adjust_corners, :notch_count, :v1, :v2

        # @return [Array<Integer>] the ends that get a corner box when +corners+ is set: 1 for p1, 2 for p2
        attr_accessor :corner_ends

        def initialize(outside, inside, options = {})
          self.outside = outside.clone
          self.inside = inside.clone

          # two vectors representing directions going from beginning of each inside line to the outside
          self.v1 = [inside.p1.x - outside.p1.x, inside.p1.y - outside.p1.y].map{ |e| -(e / e.abs).to_f }
          self.v2 = [inside.p2.x - outside.p2.x, inside.p2.y - outside.p2.y].map{ |e| -(e / e.abs).to_f }

          self.v1 = Vector.[](*v1)
          self.v2 = Vector.[](*v2)

          self.center_out = options[:center_out] || false
          self.thickness = options[:thickness]
          self.corners = options[:corners]
          self.corner_ends = options[:corner_ends] || ENDS
          self.kerf = options[:kerf] || 0
          self.notch_width = options[:notch_width]
          self.adjust_corners = options[:adjust_corners]

          adjust_for_kerf!
          calculate_notch_width!
        end

        def adjust_for_kerf!
          return unless kerf?

          self.inside  = move_line_for_kerf(inside)
          self.outside = move_line_for_kerf(outside)
        end

        def move_line_for_kerf(line)
          k = kerf / 2.0
          p1 = line.p1.plus(v1 * k)
          p2 = line.p2.plus(v2 * k)
          Geometry::Line.new(p1, p2).relocate!
        end

        def kerf?
          kerf > 0.0
        end

        # Whether this edge draws a corner box at the given end.
        #
        # @param end_index [Integer] 1 for p1, 2 for p2
        # @return [Boolean]
        def corner_at?(end_index)
          corners ? corner_ends.include?(end_index) : false
        end

        # face_setting determines if we want that face to have center notch
        # facing out (for a hole, etc).  This works well when we have odd number
        # of notches, but
        def add_across_line?(face_setting)
          notch_count % 4 == 1 ? face_setting : !face_setting
        end

        # True if the first notch should be a tab (sticking out), or false if it's a hole.
        def first_notch_out?
          add_across_line?(center_out)
        end

        private

        def calculate_notch_width!
          length = kerf? ? inside.length - kerf : inside.length
          # Rounded before #ceil: when the notch divides the side exactly,
          # float noise in the coordinates would otherwise decide the count,
          # and the two panels meeting at this joint would disagree.
          count = (length / notch_width).to_f.round(RATIO_DIGITS).ceil + 1
          count = (count / 2 * 2) + 1 # make count always an odd number
          count = [MINIMUM_NOTCHES_PER_SIDE, count].max
          self.notch_width = 1.0 * length / count
          self.notch_count = count
        end
      end
    end
  end
end
