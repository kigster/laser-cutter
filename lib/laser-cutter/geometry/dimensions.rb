module Laser
  module Cutter
    module Geometry
      class Dimensions < Tuple

        def w
          coordinates[0]
        end

        def h
          coordinates[1]
        end

        def d
          coordinates[2]
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
