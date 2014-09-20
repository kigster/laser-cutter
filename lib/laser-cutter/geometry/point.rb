module Laser
  module Cutter
    module Geometry
      class Point < Tuple
        def x= value
          coordinates[0] = value
        end

        def x
          coordinates[0]
        end

        def y= value
          coordinates[1] = value
        end

        def y
          coordinates[1]
        end

        def separator
          ','
        end

        def hash_keys
          [:x, :y]
        end
      end
    end
  end
end
