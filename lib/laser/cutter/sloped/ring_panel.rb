# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # One of the rectangular panels that wrap around the sloped box between
      # its two side walls: the bottom, the back, a strip or the tilted panel.
      #
      # In its own frame the panel is +width+ along x, from one side wall to
      # the other, and +length+ along y, from its near edge to its far edge.
      #
      #         far edge
      #     3 +----------+ 2
      #       |          |
      #   end |          | end
      #       |          |
      #     0 +----------+ 1
      #         near edge
      #
      # - A long edge is notched into the panel beyond it, or plain.
      # - An end is notched into the side wall from the near edge as far as
      #   +joint+, and from there on covers the edge of the side wall, one
      #   thickness out. A strip ends that way, past the corner of the wall,
      #   and so does a tilted panel that lifts off, along its whole length.
      # - A corner next to two notched edges may carry the corner cube.
      class RingPanel
        # Which way is out of the panel across its left end, near edge, right
        # end and far edge. Corner n lies between entry n and the one after.
        OUTWARDS = [[-1, 0], [0, -1], [1, 0], [0, 1]].freeze

        # @param notcher [Notcher]
        # @param width [Numeric] between the side walls
        # @param length [Numeric] from the near edge to the far edge
        # @param near [Boolean, nil] the middle notch of the near edge: true for a tab, false for a hole, nil for a plain edge
        # @param far [Boolean, nil] the same, for the far edge
        # @param joint [Numeric] how far along each end, from the near edge, the notches into the side wall run
        # @param corners [Array<Symbol>] the edges whose two corners this panel carries: :near, :far
        def initialize(notcher:, width:, length:, joint:, near: nil, far: nil, corners: [])
          @notcher = notcher
          @width = width.to_f
          @length = length.to_f
          @joint = joint.to_f
          @near = near
          @far = far
          @corners = corners
          freeze
        end

        # @return [Geometry::Loop] the outline, counter-clockwise from the near left corner
        def loop
          Geometry::Loop.new(near_edge + corner(1) + right_end + corner(2) + far_edge + corner(3) + left_end + corner(0))
        end

        private

        def thickness = @notcher.thickness

        def point(x, y) = Geometry::Point[x, y]

        def near_edge
          @near.nil? ? [] : @notcher.path(point(0, 0), point(@width, 0), center_out: @near)
        end

        def far_edge
          @far.nil? ? [] : @notcher.path(point(@width, @length), point(0, @length), center_out: @far)
        end

        # Up the right end: the notches, then the stretch that covers the wall.
        def right_end
          notched(point(@width, 0), point(@width, @joint)) + covering(@width + thickness, @joint, @length)
        end

        # Down the left end, the same two stretches the other way round.
        def left_end
          covering(-thickness, @length, @joint) + notched(point(0, @joint), point(0, 0))
        end

        def notched(from, to)
          @joint.positive? ? @notcher.path(from, to, center_out: true) : []
        end

        def covering(x, from, to)
          @joint < @length ? [point(x, from), point(x, to)] : []
        end

        # The square on a corner this panel carries: out along the edge that
        # arrives, round the outer corner, and back along the edge that leaves.
        # The outline then passes the inner corner twice, and Loop drops the
        # spikes that leaves wherever a tab runs into the square.
        def corner(index)
          return [] unless @corners.include?(index < 2 ? :near : :far)

          inner = point(index.between?(1, 2) ? @width : 0.0, index < 2 ? 0.0 : @length)
          arriving, leaving = [OUTWARDS[index], OUTWARDS[(index + 1) % 4]].map { |x, y| Vector[x, y] * thickness }
          [inner, inner.plus(arriving), inner.plus(arriving + leaving), inner.plus(leaving), inner]
        end
      end
    end
  end
end
