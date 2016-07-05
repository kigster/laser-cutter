require 'laser-cutter/helpers/shapes'
module Laser
  module Cutter
    module Model
      MINIMUM_NOTCHES_PER_SIDE = 3
      # +Edge+ represents one edge (out of four total, representing one face
      # of a box).
      #
      # Internally we chose to think of an notched edge as an alternating
      # path that bends at right angles and is weaves in between two parallel
      # lines:
      #
      #  * the __outer__ line is the line that represents physical bounds of one side
      #    of the face of the box
      #  * the __inner__ line is the line on the face that is exactly
      #    below the outer line, but shifted by the amount equal to the material
      #    thickness.
      #
      # The distance between the outer and inner lines, is therefore equal to the
      # height of the teeth (a.k.a. notches).
      #
      # +Edge+ is additionally responsible for calculating the "perfect" notch width.
      class Edge

        include ::Laser::Cutter::Helpers::Shapes

        attr_accessor :outer, :inner
        attr_accessor :notch
        attr_accessor :thickness, :kerf
        attr_accessor :center_out, :corners, :adjust_corners
        attr_accessor :notch_count, :v1, :v2


        def initialize(outer, inner, options = {})
          self.outer = outer.clone
          self.inner = inner.clone

          # two vectors representing directions going from beginning of each inner line to the outer
          self.v1    = [inner.p1.x - outer.p1.x, inner.p1.y - outer.p1.y].map { |e| -(e / e.abs).to_f }
          self.v2    = [inner.p2.x - outer.p2.x, inner.p2.y - outer.p2.y].map { |e| -(e / e.abs).to_f }

          self.v1 = Vector.[](*self.v1)
          self.v2 = Vector.[](*self.v2)

          self.center_out     = options[:center_out] || false
          self.thickness      = options[:thickness]
          self.corners        = options[:corners]
          self.kerf           = options[:kerf] || 0
          self.notch          = options[:notch]
          self.adjust_corners = options[:adjust_corners]

          adjust_for_kerf!
          calculate_notch!
        end

        def adjust_for_kerf!
          if kerf?
            self.inner = move_line_for_kerf(inner)
            self.outer = move_line_for_kerf(outer)
          end
        end

        def move_line_for_kerf(line)
          k  = kerf / 2.0
          p1 = line.p1.plus(v1 * k)
          p2 = line.p2.plus(v2 * k)
          _line(p1, p2).relocate!
        end

        def kerf?
          self.kerf > 0.0
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

        def calculate_notch!
          length           = kerf? ? self.inner.length - kerf : self.inner.length
          count            = (length / notch).to_f.ceil + 1
          count            = (count / 2 * 2) + 1 # make count always an odd number
          count            = [MINIMUM_NOTCHES_PER_SIDE, count].max
          self.notch       = 1.0 * length / count
          self.notch_count = count
        end

      end
    end
  end
end
