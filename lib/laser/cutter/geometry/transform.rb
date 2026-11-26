# frozen_string_literal: true

module Laser
  module Cutter
    module Geometry
      # A rotation followed by a move, from a local frame into the page.
      #
      # Notches are drawn along the x axis of a local frame, where every side
      # is horizontal and the axis-aligned notching code applies unchanged.
      # A Transform then turns and moves the result onto a side at any angle.
      class Transform
        # @return [Point] where the local origin lands
        attr_reader :origin

        # @return [Float] the turn, in radians, counter-clockwise
        attr_reader :angle

        # The frame whose x axis runs from one point towards another, with
        # its origin on the first. Its y axis points to the left of that run.
        #
        # @param from [Point]
        # @param to [Point]
        # @return [Transform]
        def self.along(from, to)
          new(from, Math.atan2(to.y - from.y, to.x - from.x))
        end

        # @param origin [Point]
        # @param angle [Numeric] radians, counter-clockwise
        def initialize(origin, angle)
          @origin = origin.clone.freeze
          @angle = angle.to_f
          @cos = Math.cos(@angle)
          @sin = Math.sin(@angle)
          freeze
        end

        # @param shape [Point, Line] in the local frame
        # @return [Point, Line] a new shape, on the page
        def apply(shape)
          case shape
          when Line then Line.new(apply(shape.p1), apply(shape.p2))
          when Point then Point[origin.x + (shape.x * @cos) - (shape.y * @sin), origin.y + (shape.x * @sin) + (shape.y * @cos)]
          else raise ArgumentError, "cannot transform #{shape.class}"
          end
        end
      end
    end
  end
end
