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

        def create(instance, *args, &block)
          instance.extend(InstanceMethods) unless instance.respond_to?(:hashie_mash)
          result = nil
           instance.instance_eval do
            result = block.call(*args)
          end
          result
        end

        module InstanceMethods

          def path_inferator(*args)
            Laser::Cutter::Strategy::Path::InfiniteIterator.new(*args)
          end

          def path_shift(*args)
            Laser::Cutter::Strategy::Path::Shift.new(*args)
          end

          def line(*coords)
            Laser::Cutter::Geometry::Line[*coords]
          end

          def point(*coords)
            Laser::Cutter::Geometry::Point[*coords]
          end

          def rectangle(*points)
            Laser::Cutter::Geometry::Rect[*points]
          end

          def dimensions(*coords)
            Laser::Cutter::Geometry::Dimensions.new(*coords)
          end

          def box(*args)
            Laser::Cutter::Model::Box.new(*args).construct
          end

          def edge(*args)
            Laser::Cutter::Model::Edge.new(*args)
          end

          def aggregator(lines = [])
            Laser::Cutter::Strategy::Aggregator.new(lines)
          end

          def path_finder(edge)
            Laser::Cutter::Strategy::PathGenerator.new(edge)
          end

          def hashie_mash(*args)
            Hashie::Mash.new(*args)
          end
        end

        extend self
      end
    end
  end
end

