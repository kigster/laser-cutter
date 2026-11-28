# frozen_string_literal: true

# Reads an outline as a walk around a panel, without using any of the code
# that drew it: where its tabs are along a joint, whether it crosses itself,
# and the loop a pile of lines makes.
module Loops
  module_function

  # How far apart two numbers may be and still be the same.
  CLOSE = 1e-6

  # The stretches of a joint where a panel has a tab: where its outline runs
  # one thickness out, to the right of the way the joint is walked.
  #
  # @param lines [Array<Laser::Cutter::Geometry::Line>] the outline of the panel
  # @param from [Laser::Cutter::Geometry::Point] where the joint begins, on the inside outline
  # @param to [Laser::Cutter::Geometry::Point] where it ends
  # @param thickness [Float] of the material
  # @return [Array<Array(Float, Float)>] each tab as the distances from +from+ it starts and ends at, in order
  def tabs(lines, from:, to:, thickness:)
    length = Math.hypot(to.x - from.x, to.y - from.y)
    along = [(to.x - from.x) / length, (to.y - from.y) / length]
    place = lambda do |point|
      delta = [point.x - from.x, point.y - from.y]
      [(delta[0] * along[0]) + (delta[1] * along[1]), (delta[0] * along[1]) - (delta[1] * along[0])]
    end
    runs = lines.map { |line| [place.call(line.p1), place.call(line.p2)] }
                .select { |ends| ends.all? { |_distance, out| (out - thickness).abs < CLOSE } }
                .map { |ends| ends.map(&:first).sort.map { |distance| distance.clamp(0.0, length) } }
    runs.reject { |start, finish| finish - start < CLOSE }.sort
  end

  # Whether the tabs of two panels fill a joint between them, each stretch
  # of it a tab of one panel or the other and never of both. The two panels
  # walk the joint in opposite directions.
  #
  # @param ours [Array<Array(Float, Float)>] the tabs of one panel, see {tabs}
  # @param theirs [Array<Array(Float, Float)>] the tabs of the other
  # @param length [Float] of the joint
  # @return [Boolean]
  def interlock?(ours, theirs, length)
    turned = theirs.map { |start, finish| [length - finish, length - start] }
    edges = (ours + turned).sort.flatten
    return false unless ours.any? && theirs.any?

    edges.first.abs < CLOSE && (edges.last - length).abs < CLOSE &&
      edges[1..-2].each_slice(2).all? { |finish, start| (finish - start).abs < CLOSE }
  end

  # Whether no two sides of an outline cross, or touch anywhere but at the
  # corner two neighbours share.
  #
  # @param lines [Array<Laser::Cutter::Geometry::Line>] the sides, end to end
  # @return [Boolean]
  def simple?(lines)
    lines.each_with_index.none? do |line, index|
      ((index + 2)...lines.size).any? do |other|
        next false if index.zero? && other == lines.size - 1

        touch?(line, lines[other])
      end
    end
  end

  def touch?(first, second)
    turns = [[first, second.p1], [first, second.p2], [second, first.p1], [second, first.p2]].map do |line, point|
      ((line.p2.x - line.p1.x) * (point.y - line.p1.y)) - ((line.p2.y - line.p1.y) * (point.x - line.p1.x))
    end
    return false if turns.all? { |turn| turn.abs < CLOSE } && !overlap?(first, second)

    (turns[0] * turns[1]) <= CLOSE && (turns[2] * turns[3]) <= CLOSE
  end

  # Whether two lines along the same straight line share a stretch of it.
  def overlap?(first, second)
    axis = (first.p2.x - first.p1.x).abs > (first.p2.y - first.p1.y).abs ? 0 : 1
    a = [first.p1[axis], first.p2[axis]].sort
    b = [second.p1[axis], second.p2[axis]].sort
    a[0] <= b[1] + CLOSE && b[0] <= a[1] + CLOSE
  end

  # The loop that lines make when each ends where another begins.
  #
  # @param lines [Array<Laser::Cutter::Geometry::Line>] in any order
  # @return [Laser::Cutter::Geometry::Loop]
  def chain(lines)
    key = ->(point) { point.to_a.map { |c| c.round(6) + 0.0 } }
    meeting = lines.flat_map { |line| [[key.call(line.p1), line], [key.call(line.p2), line]] }
                   .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
    line = lines.first
    at = line.p2
    points = lines.drop(1).each_with_object([line.p1]) do |_, walked|
      walked << at
      line = meeting.fetch(key.call(at)).find { |candidate| !candidate.equal?(line) }
      at = key.call(line.p1) == key.call(at) ? line.p2 : line.p1
    end
    Laser::Cutter::Geometry::Loop.new(points)
  end

  # Lines as sorted, rounded pairs of points, so two outlines compare whatever their order.
  #
  # @return [Array<Array<Array(Float, Float)>>]
  def rounded(lines)
    lines.map { |line| [line.p1, line.p2].map { |point| point.to_a.map { |c| c.round(5) + 0.0 } }.sort }.sort
  end
end
