module Laser
  module Cutter
    module Geometry
      MINIMUM_NOTCHES_PER_SIDE = 3
    end
  end
end

require 'laser-cutter/geometry/tuple'
require 'laser-cutter/geometry/dimensions'
require 'laser-cutter/geometry/point'
require 'laser-cutter/geometry/shape'
require 'laser-cutter/geometry/edge'
require 'laser-cutter/geometry/path_generator'
