# frozen_string_literal: true

module Laser
  module Cutter
    # Merges the lines of one face into the outline to cut.
    #
    # Each edge draws its own notch path and its own corner boxes, so where
    # two of them meet the same stretch is drawn twice, once from each side.
    # That stretch runs through the material and must not be cut. So every
    # collinear group of lines is combined as a symmetric difference: a point
    # is cut when an odd number of lines cover it. Two identical lines cancel,
    # two overlapping lines keep only the parts they do not share, and lines
    # that touch or overlap end to end join into one.
    #
    # Lines are grouped by axis and offset, sorted, and swept once, so a face
    # of n lines takes n log n. Lines on neither axis pass through untouched.
    class Aggregator
      # Coordinates this close together count as the same.
      TOLERANCE = Math.sqrt(Geometry::Tuple::PRECISION)

      # @return [Array<Geometry::Line>] the outline, sorted
      attr_reader :lines

      # @param lines [Array<Geometry::Line>]
      def initialize(lines = [])
        @lines = (sweep(lines, 0) + sweep(lines, 1) + skewed(lines)).sort
      end

      private

      # Lines running along one axis: 0 for horizontal (constant y), 1 for vertical (constant x).
      #
      # @return [Array<Geometry::Line>]
      def sweep(lines, axis)
        across = (axis + 1) % 2
        along = lines.select { |line| along?(line, axis) }
        groups(along, across).flat_map { |offset, group| cut_intervals(group, axis, offset, across) }
      end

      def skewed(lines)
        lines.reject { |line| along?(line, 0) || along?(line, 1) }
      end

      def along?(line, axis)
        across = (axis + 1) % 2
        (line.p1[across] - line.p2[across]).abs <= TOLERANCE && (line.p1[axis] - line.p2[axis]).abs > TOLERANCE
      end

      # Lines on the same row or column, keyed by the offset of the first one seen.
      def groups(lines, across)
        lines.sort_by { |line| line.p1[across] }.slice_when { |a, b| b.p1[across] - a.p1[across] > TOLERANCE }
             .to_h { |group| [group.first.p1[across], group] }
      end

      # Sweeps the endpoints of one collinear group, keeping the stretches an
      # odd number of lines cover.
      def cut_intervals(group, axis, offset, across)
        events = group.flat_map do |line|
          from, to = [line.p1[axis], line.p2[axis]].sort
          [[from, 1], [to, -1]]
        end
        events.sort_by! { |position, step| [position, step] }

        intervals = []
        covered = 0
        started = nil
        events.each do |position, step|
          was = covered
          covered += step
          if was.even? && covered.odd?
            started = position
          elsif was.odd? && covered.even?
            extend_or_add(intervals, started, position)
          end
        end
        intervals.map { |from, to| line_between(from, to, axis, offset, across) }
      end

      # Joins an interval onto the last one when they touch, and drops one with no length.
      def extend_or_add(intervals, from, to)
        return if to - from <= TOLERANCE

        last = intervals.last
        if last && from - last[1] <= TOLERANCE
          last[1] = to
        else
          intervals << [from, to]
        end
      end

      def line_between(from, to, axis, offset, across)
        a = []
        b = []
        a[axis] = from
        b[axis] = to
        a[across] = b[across] = offset
        Geometry::Line.new(Geometry::Point[*a], Geometry::Point[*b])
      end
    end
  end
end
