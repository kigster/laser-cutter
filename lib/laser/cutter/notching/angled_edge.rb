# frozen_string_literal: true

module Laser
  module Cutter
    module Notching
      # Notches along a side at any angle: the sloped side of a wall under a
      # tilted panel.
      #
      # It lays the side flat along the x axis of a local frame, notches it
      # there with the same Edge and PathGenerator every other side uses, and
      # turns the lines back onto the side. A side of the same length therefore
      # gets the same notch count and width wherever it points, so a tilted
      # panel, itself a plain rectangle, mates with the sloped wall.
      #
      # It draws no corner boxes: the corners of a sloped side are not square.
      # Kerf moves the ends along the side as it does on a square corner, which
      # is close but not exact when the corner is not square.
      class AngledEdge
        extend ::Forwardable

        # The side of the run, from +from+ to +to+, the material lies beyond.
        SIDES = { left: 1, right: -1 }.freeze

        def_delegators :@edge, :notch_count, :notch_width, :first_notch_out?, :center_out, :thickness, :kerf

        # @return [Geometry::Transform] from the local frame onto the page
        attr_reader :transform

        # @param from [Geometry::Point] where the inside line starts
        # @param to [Geometry::Point] where it ends
        # @param outward [Symbol] :left or :right of the run from +from+ to +to+
        # @param options [Hash] as for Edge: notch_width, thickness, kerf, center_out
        def initialize(from, to, outward:, **options)
          sign = SIDES.fetch(outward) { raise ArgumentError, "outward must be one of #{SIDES.keys}, got #{outward.inspect}" }
          @transform = Geometry::Transform.along(from, to)
          @edge = Edge.new(*local_lines(Geometry::Line.new(from, to).length, options.fetch(:thickness), sign),
                           options.merge(corners: false))
        end

        # @return [Array<Geometry::Line>] the notched path, on the page
        def lines
          PathGenerator.new(@edge).generate.map { |line| transform.apply(line) }
        end

        private

        # The outside and inside lines of a side of the given length, laid
        # along the local x axis, the way Box pairs a face with its bounds.
        def local_lines(length, thickness, sign)
          offset = sign * thickness
          outside = Geometry::Line.new(Geometry::Point[-thickness, offset], Geometry::Point[length + thickness, offset])
          inside = Geometry::Line.new(Geometry::Point[0, 0], Geometry::Point[length, 0])
          [outside, inside]
        end
      end
    end
  end
end
