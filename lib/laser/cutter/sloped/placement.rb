# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # Where a panel goes on the sheet: its own origin moved to a point, and
      # the panel turned over within its own size when asked. Flipping x draws
      # the mirror image, which the second side wall is; flipping both turns
      # the panel half way round.
      class Placement
        # @return [Geometry::Point] where the origin of the panel lands
        attr_reader :origin

        # @param origin [Geometry::Point] where the origin of the panel lands
        # @param size [Array(Numeric, Numeric)] the width and length a flip turns the panel within
        # @param flip_x [Boolean] whether x runs from the far side back
        # @param flip_y [Boolean] whether y runs from the far side back
        def initialize(origin, size:, flip_x: false, flip_y: false)
          @origin = origin.clone
          @size = size.map(&:to_f).freeze
          @flip_x = flip_x
          @flip_y = flip_y
          freeze
        end

        # @param point [Geometry::Point] in the frame of the panel
        # @return [Geometry::Point] on the sheet
        def apply(point)
          x = @flip_x ? @size[0] - point.x : point.x
          y = @flip_y ? @size[1] - point.y : point.y
          Geometry::Point[@origin.x + x, @origin.y + y]
        end
      end
    end
  end
end
