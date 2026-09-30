# frozen_string_literal: true

module Laser
  module Cutter
    module Notching
      class PathGenerator
        extend ::Forwardable

        %i(center_out thickness corners kerf kerf? notch_width first_notch_out? adjust_corners corners).each do |method_name|
          def_delegator :@edge, method_name, method_name
        end

        attr_accessor :edge

        # This class generates lines that zigzag between two lines: the outside line, and the
        # inside line of a single edge. Edge class encapsulates both of them with additional
        # properties.
        def initialize(edge)
          @edge = edge
        end

        # Calculates a notched path that flows between the outer edge of the box
        # (outside_line) and inner (inside_line).  Relative location of these lines
        # also defines the direction and orientation of the box, and hence the notches.
        #
        # We always want to create a symmetric path that has a notch in the middle
        # (for center_out = true) or dip in the middle (center_out = false)
        def generate
          lines = []
          lines << corner_box_sides if corners
          lines << notch_lines
          lines.flatten
        end

        # The zigzag alone, without the corner boxes.
        #
        # @return [Array<Geometry::Line>]
        def notch_lines
          point = starting_point
          vertices = [point]
          adjust_for_kerf(vertices, -1) if adjust_end?(1)
          define_shifts.each do |shift|
            point = shift.next_point_after point
            vertices << point
          end
          adjust_for_kerf(vertices, 1) if adjust_end?(2)
          create_lines(vertices)
        end

        def adjust_for_kerf(vertices, direction)
          return unless kerf?

          point = vertices.pop
          point = point.plus(2 * direction * shift_vector(1))
          vertices << point
        end

        def corner_box_sides
          ends = Edge::ENDS.select { |end_index| edge.corner_at?(end_index) }

          # These boxes occupy the corners of the 3D box. They do not match
          # in width to our notches because they are usually merged with them.
          # It's just an aesthetic choice I guess.
          boxes = ends.map { |end_index| Geometry::Rect[inside_point(end_index).clone, outside_point(end_index).clone] }
          sides = boxes.map(&:relocate!).map(&:sides)
          sides << ends.map { |end_index| kerf_strip(end_index) } if kerf? && adjust_corners
          sides.flatten
        end

        # Widens the corner box at one end by the kerf, on the side where
        # nothing is attached to it: along the edge when the first notch is a
        # hole, across it when the first notch is a tab.
        #
        # @param end_index [Integer] 1 for p1, 2 for p2
        # @return [Array<Geometry::Line>]
        def kerf_strip(end_index)
          inside = inside_point(end_index)
          outside = outside_point(end_index)
          along, across = first_notch_out? ? [outside, inside] : [inside, outside]
          moved = inside.plus(-2 * shift_vector(end_index, first_notch_out? ? 1 : 0))

          coords = []
          coords[d_index_along] = along[d_index_along]
          coords[d_index_across] = across[d_index_across]
          Geometry::Rect[moved, Geometry::Point[*coords]].sides << Geometry::Line[moved, inside.clone]
        end

        def shift_vector(index, dim_shift = 0)
          shift = []
          shift[(d_index_across + dim_shift) % 2] = 0
          shift[(d_index_along + dim_shift) % 2] = kerf / 2.0 * edge.send(:"v#{index}").[]((d_index_along + dim_shift) % 2)
          Vector.[](*shift)
        end

        def starting_point
          edge.inside.p1.clone # start
        end

        # 0 = X, 1 = Y
        def d_index_along
          edge.inside.p1.x == edge.inside.p2.x ? 1 : 0
        end

        def d_index_across
          (d_index_along + 1) % 2
        end

        def direction_along
          edge.inside.p1.coords.[](d_index_along) < edge.inside.p2.coords.[](d_index_along) ? 1 : -1
        end

        def direction_across
          edge.inside.p1.coords.[](d_index_across) < edge.outside.p1.coords.[](d_index_across) ? 1 : -1
        end

        private

        def inside_point(end_index)
          edge.inside.public_send(:"p#{end_index}")
        end

        def outside_point(end_index)
          edge.outside.public_send(:"p#{end_index}")
        end

        # A corner box next to a hole is widened by the kerf, so the hole starts that much later.
        def adjust_end?(end_index)
          adjust_corners && !first_notch_out? && edge.corner_at?(end_index)
        end

        # This method has the bulk of the logic: we create the list of path deltas
        # to be applied when we walk the edge next.
        # @param [Object] shift
        def define_shifts
          along_iter = create_iterator_along
          across_iter = create_iterator_across

          shifts = []
          inner = true # false when we are drawing outer notch, true when inner

          if first_notch_out?
            shifts << across_iter.next
            inner = !inner
          end

          (1..edge.notch_count).to_a.each do |notch_number|
            shifts << along_iter.next do |shift, _index|
              if inner && notch_number > 1 && notch_number < edge.notch_count
                shift.delta -= kerf
              elsif !inner
                shift.delta += kerf
              end
              inner = !inner
              shift
            end
            shifts << across_iter.next unless notch_number == edge.notch_count
          end

          shifts << across_iter.next if first_notch_out?
          shifts
        end

        # As we draw notches, shifts define the 'delta' – movement from one point
        # to the next.  This method defines three types of movements we'll be doing:
        # one alongside the edge, and two across (towards the box and outward from the box)
        def create_iterator_along
          InfiniteIterator.new([Shift.new(notch_width, direction_along, d_index_along)])
        end

        def create_iterator_across
          InfiniteIterator.new([Shift.new(thickness, direction_across, d_index_across),
                                Shift.new(thickness, -direction_across, d_index_across)])
        end

        def create_lines(vertices)
          lines = []
          vertices.each_with_index do |v, i|
            if v != vertices.last
              lines << Geometry::Line.new(v, vertices[i + 1])
            end
          end
          lines.flatten
        end
      end
    end
  end
end
