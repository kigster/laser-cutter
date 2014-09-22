module Laser
  module Cutter
    module Geometry
      # This class represents a single edge of one side: both inside
      # and outside edge of the material.  It's also responsible
      # for calculating the "perfect" notch width.
      class Edge < Struct.new(:outside, :inside, :notch_width)
        attr_accessor :notch_count

        def initialize(*args)
          super(*args)
          adjust_notch(self.inside)
        end

        def adjust_notch(line)
          d = (line.length / notch_width).to_f.ceil
          pairs = d / 2
          d = pairs * 2 + 1
          d = MINIMUM_NOTCHES_PER_SIDE if d < MINIMUM_NOTCHES_PER_SIDE
          self.notch_width = line.length / (1.0 * d)
          self.notch_count = d
        end

        # face_setting determines if we want that face to have center notch
        # facing out (for a hole, etc).  This works well when we have odd number
        # of notches, but
        def add_across_line?(face_setting)
          notch_count % 4 == 1 ? face_setting : !face_setting
        end
      end
    end
  end
end
