# frozen_string_literal: true

module Laser
  module Cutter
    module Geometry
      # A closed outline: points in order, the last joined back to the first.
      #
      # A panel is drawn by walking its edges in turn, which leaves the walk
      # with points it does not need: the same point twice where two edges
      # meet, a spike where one edge steps out and the next steps straight
      # back, and points in the middle of a straight run. A Loop drops all
      # three, so what is left has one point for each corner.
      #
      # It cannot be changed: #grow and #map return a new Loop.
      class Loop
        # Lengths this close to zero, relative to the lines measured, are zero.
        EPSILON = 1e-9

        # @param points [Array<Point>] the walk around the outline
        # @raise [ArgumentError] when fewer than three corners are left, or they enclose nothing
        def initialize(points)
          @corners = tidy(points.map(&:clone)).freeze
          raise ArgumentError, "an outline needs three corners, got #{@corners.size}" if @corners.size < 3
          raise ArgumentError, 'an outline needs an area, but its corners lie on one line' if area <= EPSILON

          freeze
        end

        # @return [Array<Point>] a copy of the corners, in the order given
        def points
          @corners.map(&:clone)
        end

        # @return [Array<Line>] one line for each side, end to end
        def lines
          @corners.each_with_index.map { |point, index| Line.new(point, @corners[(index + 1) % @corners.size]) }
        end

        # @return [Float] the area enclosed, positive whichever way the points run
        def area
          signed_area.abs
        end

        # The outline moved outwards by a distance on every side, the corners
        # kept sharp. Half the kerf makes a panel cut to size.
        #
        # @param distance [Numeric] outwards when positive
        # @return [Loop]
        def grow(distance)
          return self if distance.zero?

          side = signed_area.positive? ? 1 : -1
          normals = lines.map { |line| outward(line, side) }
          Loop.new(@corners.each_with_index.map { |point, index| mitre(point, normals[index - 1], normals[index], distance) })
        end

        # @yieldparam point [Point]
        # @yieldreturn [Point]
        # @return [Loop] the outline with every corner mapped
        def map(&)
          Loop.new(@corners.map(&))
        end

        private

        def signed_area
          lines.sum { |line| (line.p1.x * line.p2.y) - (line.p2.x * line.p1.y) } / 2.0
        end

        # The unit normal of a line that points out of the outline.
        def outward(line, side)
          length = line.length
          Vector[side * (line.p2.y - line.p1.y) / length, side * (line.p1.x - line.p2.x) / length]
        end

        # Where the two sides that meet at a corner cross once each has moved out.
        def mitre(point, before, after, distance)
          point.plus((before + after) * (distance / (1 + before.inner_product(after))))
        end

        # Drops what a walk leaves behind until nothing more can go.
        def tidy(points)
          loop do
            kept = points.each_with_index.reject { |_point, index| needless?(points, index) }.map(&:first)
            return kept if kept.size == points.size || kept.size < 3

            points = kept
          end
        end

        # Only the first of two such points in a row goes in one pass, since
        # dropping one changes the neighbours of the other.
        def needless?(points, index)
          removable?(points, index) && !removable?(points, index - 1)
        end

        # Whether a point repeats the one before it, or lies on the straight
        # line through its neighbours: in the middle of a run, or at the tip
        # of a spike.
        def removable?(points, index)
          before = points[index - 1]
          point = points[index]
          after = points[(index + 1) % points.size]
          incoming = Math.hypot(point.x - before.x, point.y - before.y)
          return true if incoming <= EPSILON

          cross = ((point.x - before.x) * (after.y - point.y)) - ((point.y - before.y) * (after.x - point.x))
          cross.abs <= EPSILON * incoming * Math.hypot(after.x - point.x, after.y - point.y)
        end
      end
    end
  end
end
