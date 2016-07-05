require_relative '../tuple'
module Laser
  module Cutter
    module Geometry
      class Dimensions < Tuple

        def w
          coords.[](0)
        end

        def h
          coords.[](1)
        end

        def d
          coords.[](2)
        end

        def separator
          'x'
        end

        def hash_keys
          [:w, :h, :d]
        end

      end
    end
  end

end
