# frozen_string_literal: true

# Reads the lines of one panel as the region they enclose, without using any
# of the code that drew them.
module Outline
  module_function

  # Whether a point is inside the outline, by the even-odd rule: a ray from
  # the point crosses the outline an odd number of times.
  #
  # @param lines [Array<Laser::Cutter::Geometry::Line>] an outline of horizontal and vertical lines
  # @return [Boolean]
  def inside?(lines, x, y)
    lines.count do |line|
      next false unless line.p1.x == line.p2.x && line.p1.x > x

      low, high = [line.p1.y, line.p2.y].sort
      low < y && y < high
    end.odd?
  end

  # Whether the outline grown by a margin on every side covers the point.
  #
  # @return [Boolean]
  def within?(lines, x, y, margin)
    offsets = [-margin, 0, margin]
    offsets.product(offsets).any? { |dx, dy| inside?(lines, x + dx, y + dy) }
  end

  # Whether every line ends where another begins, so the outline has no gap.
  #
  # @return [Boolean]
  def closed?(lines)
    ends = lines.flat_map { |line| [line.p1, line.p2] }.map { |point| point.to_a.map { |c| c.round(6) + 0.0 } }
    ends.tally.values.all?(&:even?)
  end

  # Points spread over a rectangle, off any round coordinate a line could sit on.
  #
  # @param rect [Laser::Cutter::Geometry::Rect]
  # @param margin [Float] how far past the rectangle to reach
  # @param steps [Integer] points per axis
  # @return [Array<Array(Float, Float)>]
  def samples(rect, margin:, steps: 61)
    xs = spread(rect.p1.x - margin, rect.p2.x + margin, steps)
    ys = spread(rect.p1.y - margin, rect.p2.y + margin, steps)
    xs.product(ys)
  end

  def spread(from, to, steps)
    Array.new(steps) { |i| from + ((to - from) * (i + 0.4142) / steps) }
  end
end
