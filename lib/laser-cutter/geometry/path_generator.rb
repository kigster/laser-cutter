require_relative 'notched_path'

module Laser
  module Cutter
    module Geometry
      class Shift < Struct.new(:delta, :direction, :dim_index)
        POINTERS = {[1, 0]  => '   ->',
                    [-1, 0] => '<-   ',
                    [1, 1]  => '  V  ',
                    [-1, 1] => '  ^  '}

        def next(point1)
          p = Point.new(point1.to_a)
          p.coords[dim_index] += (delta * direction)
          p
        end
        def to_s
          "shift by:#{sprintf('%.2f', delta)}, #{POINTERS[[direction,dim_index]]}"
        end
      end

      # Alternating iterator
      class InfiniteIterator < Struct.new(:shift_array)
        attr_accessor :current_index
        def next
          self.current_index = -1 if current_index.nil?
          self.current_index += 1
          self.current_index = current_index % shift_array.size
          shift_array[current_index]
        end
      end

      class PathGenerator
        # Removes the items from the list that appear more than once
        # Unlike uniq-ing which keeps all elements, just ensures that are not
        # repeated, here we remove elements completely if they are seen more than once.
        # This is used to remove lines that join the same two points.
        def self.deduplicate list
          new_list = []
          list.sort!
          list.each_with_index do |e, i|
            next if i < (list.size - 1) && e.eql?(list[i + 1])
            next if i > 0 && e.eql?(list[i - 1])
            new_list << e
          end
          new_list
        end

        attr_accessor :notch_width, :thickness
        attr_accessor :center_out, :fill_corners

        def initialize(options = {})
          @notch_width = options[:notch_width]    # only desired, will be adapted for each line
          @center_out = options[:center_out]      # when true, the notch in the middle of the edge is out, not in.
          @thickness = options[:thickness]
          @fill_corners = options[:fill_corners]
        end

        # Calculates a notched path that flows between the outer edge of the box
        # (outside_line) and inner (inside_line).  Relative location of these lines
        # also defines the direction and orientation of the box, and hence the notches.
        #
        # We always want to create a symmetric path that has a notch in the middle
        # (for center_out = true) or dip in the middle (center_out = false)
        def path(edge)
          shifts = define_shifts(edge)

          path = NotchedPath.new

          if fill_corners
            r1 = Geometry::Rect.new(edge.inside.p1, edge.outside.p1)
            r2 = Geometry::Rect.new(edge.inside.p2, edge.outside.p2)
            path.corner_boxes << r1
            path.corner_boxes << r2
          end

          point = edge.inside.p1.clone
          vertices = [point]
          shifts.each do |shift|
            point = shift.next(point)
            vertices << point
          end
          path.vertices = vertices
          path
        end

        private

        # This method has the bulk of the logic: we create the list of path deltas
        # to be applied when we walk the edge next.
        def define_shifts(edge)
          along_iterator, across_iterator = define_shift_iterators(edge)
          shifts = []

          shifts << across_iterator.next if edge.add_across_line?(center_out)

          (1..edge.notch_count).to_a.each do |count|
            shifts << along_iterator.next
            shifts << across_iterator.next unless count == edge.notch_count
          end

          shifts << across_iterator.next if edge.add_across_line?(center_out)
          shifts
        end

        # As we draw notches, shifts define the 'delta' – movement from one point
        # to the next.  This method defines three types of movements we'll be doing:
        # one alongside the edge, and two across (towards the box and outward from the box)
        def define_shift_iterators(edge)
          alongside_dimension = (edge.inside.p1.x == edge.inside.p2.x) ? 1 : 0
          alongside_direction = (edge.inside.p1.coords[alongside_dimension] <
              edge.inside.p2.coords[alongside_dimension]) ? 1 : -1

          across_dimension = (alongside_dimension + 1) % 2
          across_direction = (edge.inside.p1.coords[across_dimension] >
              edge.outside.p1.coords[across_dimension]) ? -1 : 1

          [
           InfiniteIterator.new(
               [Shift.new(edge.notch_width, alongside_direction, alongside_dimension)]),
           InfiniteIterator.new(
               [Shift.new(thickness, across_direction, across_dimension),
                Shift.new(thickness, -across_direction, across_dimension)])
          ]
        end
      end
    end
  end
end
