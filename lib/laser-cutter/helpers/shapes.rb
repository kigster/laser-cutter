require 'hashie/mash'
require 'laser-cutter/geometry'
require 'laser-cutter/geometry/shape'
require 'laser-cutter/geometry/shape/rect'
require 'laser-cutter/geometry/shape/line'
require 'laser-cutter/geometry/tuple/dimensions'
require 'laser-cutter/geometry/tuple/point'
require 'laser-cutter/model/box'

module Laser
  module Cutter
    module Helpers
      module Shapes
        def _line(*coords)
          Laser::Cutter::Geometry::Line[*coords]
        end

        def _point(*coords)
          Laser::Cutter::Geometry::Point[*coords]
        end

        def _rect(*points)
          Laser::Cutter::Geometry::Rect[*points]
        end

        def _dimensions(*coords)
          Laser::Cutter::Geometry::Dimensions.new(*coords)
        end

        def _box(*args)
          Laser::Cutter::Model::Box.new(*args).construct
        end

        def _edge(*args)
          Laser::Cutter::Model::Edge.new(*args)
        end

        def _mash(*args)
          Hashie::Mash.new(*args)
        end
      end
    end
  end
end

