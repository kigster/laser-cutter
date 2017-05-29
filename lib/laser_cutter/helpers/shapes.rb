require 'hashie/mash'
require 'laser_cutter/geometry'
require 'laser_cutter/geometry/shape'
require 'laser_cutter/geometry/shape/rect'
require 'laser_cutter/geometry/shape/line'
require 'laser_cutter/geometry/tuple/dimensions'
require 'laser_cutter/geometry/tuple/point'
require 'laser_cutter/model/box'
module LaserCutter
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
          LaserCutter::Strategy::Path::InfiniteIterator.new(*args)
        end

        def path_shift(*args)
          LaserCutter::Strategy::Path::Shift.new(*args)
        end

        def line(*coords)
          LaserCutter::Geometry::Line[*coords]
        end

        def point(*coords)
          LaserCutter::Geometry::Point[*coords]
        end

        def rectangle(*points)
          LaserCutter::Geometry::Rect[*points]
        end

        def dimensions(*coords)
          LaserCutter::Geometry::Dimensions.new(*coords)
        end

        def box(*args)
          LaserCutter::Model::Box.new(*args).construct
        end

        def edge(*args)
          LaserCutter::Model::Edge.new(*args)
        end

        def aggregator(lines = [])
          LaserCutter::Strategy::Aggregator.new(lines)
        end

        def path_finder(edge)
          LaserCutter::Strategy::PathGenerator.new(edge)
        end

        def hashie_mash(*args)
          Hashie::Mash.new(*args)
        end
      end

      extend self
    end
  end
end

