module Laser
  module Cutter
    module Geometry
      class Point < Tuple
        def self.[](*array)
          Point.new *array
        end
      end
    end
  end
end
