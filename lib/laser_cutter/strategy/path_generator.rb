require 'forwardable'
require_relative 'path/infinite_iterator'
require_relative 'path/shift'
require_relative 'aggregator'
require 'laser_cutter/geometry'
require 'laser_cutter/helpers/shapes'
module LaserCutter
  module Strategy

    # One of the key "tricks" that this algorithm applies, is that it converts everything into
    # pure set of lines in the end. It then tries to find all intersections of the lines so that
    # we can remove duplicates.  So any segment of any line that is covered by 2 lines or more is removed,
    # cleared completely for an empty space.  This turns out to be very useful indeed, because we can
    # paint with wide brush strokes to get the carcass, and then fine tune it by adding or removing line
    # segments.  Some of the lines below are added to actually remove the lines that might have otherwise
    # been there.
    #
    # This comes especially handy when drawing corner boxes, which are deliberately made not to match the notch
    # width, but to match thickness of the material.  The corner notces for these sides will therefore have
    # length equal to the thickness + regular notch length.
    class PathGenerator
      include LaserCutter::Helpers::Shapes

      extend ::Forwardable
      %i(center_out thickness corners kerf kerf? notch first_notch_out? adjust_corners corners).each do |method_name|
        def_delegator :my_edge, method_name, method_name
      end

      attr_accessor :my_edge

      # This class generates lines that zigzag between two lines: the outer line, and the
      # inner line of a single edge. Edge class encapsulates both of them with additional
      # properties.
      def initialize(this_edge)
        self.my_edge = this_edge
      end

      # Calculates a notched path that flows between the outer edge of the box
      # (outer_line) and inner (inner_line).  Relative location of these lines
      # also defines the direction and orientation of the box, and hence the notches.
      #
      # We always want to create a symmetric path that has a notch in the middle
      # (for center_out = true) or dip in the middle (center_out = false)
      def generate
        shifts   = define_shifts
        vertices = []
        lines    = []

        if corners
          lines << corner_box_sides
        end

        point = starting_point

        vertices << point
        adjust_for_kerf(vertices, -1) if adjust_corners && !first_notch_out?
        shifts.each do |shift|
          point = shift.next_point_after point
          vertices << point
        end
        adjust_for_kerf(vertices, 1) if adjust_corners && !first_notch_out?
        lines << create_lines(vertices)
        aggregator = Aggregator.new(lines.flatten)
        aggregator.dedup!.deoverlap!.dedup!
        aggregator.lines.flatten
      end

      def adjust_for_kerf(vertices, direction)
        if kerf?
          point = vertices.pop
          point = corners ? point.plus(2 * direction * shift_vector(1)) : point
          vertices << point
        end
      end

      # These two boxes occupy the corners of the 3D box. They do not match
      # in width to our notches because they are usually merged with them. Their
      # size is equal to the thickness of the material (adjusted for kerf)
      # It's just an aesthetic choice I guess.
      def corner_box_sides
        boxes       = []
        extra_lines = []

        boxes << create(self) { rectangle(my_edge.inner.p1.clone, my_edge.outer.p1.clone) }
        boxes << create(self) { rectangle(my_edge.inner.p2.clone, my_edge.outer.p2.clone) }

        extra_lines << add_corners if adjust_corners && kerf?
        sides = boxes.flatten.map(&:relocate!).map(&:sides)
        sides << extra_lines unless extra_lines.empty?
        sides.flatten
      end

      def shift_vector(index, dim_shift = 0)
        shift                                   = []
        shift[(d_index_across + dim_shift) % 2] = 0
        shift[(d_index_along + dim_shift) % 2]  = kerf / 2.0 * my_edge.send("v#{index}".to_sym).[]((d_index_along + dim_shift) % 2)
        Vector.[](*shift)
      end


      def starting_point
        my_edge.inner.p1.clone # start
      end

      # 0 = X, 1 = Y
      def d_index_along
        (my_edge.inner.p1.x == my_edge.inner.p2.x) ? 1 : 0
      end

      def d_index_across
        (d_index_along + 1) % 2
      end

      def direction_along
        (my_edge.inner.p1.coords.[](d_index_along) < my_edge.inner.p2.coords.[](d_index_along)) ? 1 : -1
      end

      def direction_across
        (my_edge.inner.p1.coords.[](d_index_across) < my_edge.outer.p1.coords.[](d_index_across)) ? 1 : -1
      end

      private
      # Helper method to calculate dimensions of our corners.
      def add_corners
        k, direction, dim_index, edge_along, edge_across = if first_notch_out?
                                                             [2, -1, 1, :inner, :outer]
                                                           else
                                                             [-2, 1, 0, :outer, :inner]
                                                           end
        v1                                               = direction * k * shift_vector(1, dim_index)
        v2                                               = direction * k * shift_vector(2, dim_index)

        r1 = define_corner_rect(:p1, v1, edge_along, edge_across)
        r2 = define_corner_rect(:p2, v2, edge_along, edge_across)

        lines = [r1, r2].map(&:sides).flatten

        # Our clever algorithm removes automatically duplicate lines. These lines
        # below are added to actually clear out this space and remove the existing
        # lines that are already there.
        lines << create(self) { line(my_edge.inner.p1.plus(v1), my_edge.inner.p1.clone) }
        lines << create(self) { line(my_edge.inner.p2.plus(v2), my_edge.inner.p2.clone) }
        lines
      end

      def define_corner_rect(point, delta, edge_along, edge_across)
        p1                     = my_edge.inner.send(point).plus(delta)
        coords                 = []
        coords[d_index_along]  = my_edge.send(edge_along).send(point)[d_index_along]
        coords[d_index_across] = my_edge.send(edge_across).send(point)[d_index_across]
        p2                     = point(*coords)
        rectangle(p1, p2)
      end


      # This method has the bulk of the logic: we create the list of path deltas
      # to be applied when we walk the edge next.
      def define_shifts
        along_iter  = create_iterator_along
        across_iter = create_iterator_across

        shifts = []
        inner  = true # false when we are drawing outer notch, true when inner

        if first_notch_out?
          shifts << across_iter.next
          inner = !inner
        end

        (1..my_edge.notch_count).to_a.each do |notch_number|
          shifts << along_iter.next do |shift, index|
            if inner && (notch_number > 1 && notch_number < my_edge.notch_count)
              shift.delta -= kerf
            elsif !inner
              shift.delta += kerf
            end
            inner = !inner
            shift
          end
          shifts << across_iter.next unless notch_number == my_edge.notch_count
        end

        shifts << across_iter.next if first_notch_out?
        shifts
      end

      # As we draw notches, shifts define the 'delta' – movement from one point
      # to the next.  This method defines three types of movements we'll be doing:
      # one alongside the edge, and two across (towards the box and outward from the box)
      def create_iterator_along
        create(self) { path_inferator([Path::Shift.new(notch, direction_along, d_index_along)]) }
      end

      def create_iterator_across
        Path::InfiniteIterator.new([Path::Shift.new(thickness, direction_across, d_index_across),
                                    Path::Shift.new(thickness, -direction_across, d_index_across)])
      end

      def create_lines(vertices)
        lines = []
        vertices.each_with_index do |v, i|
          if v != vertices.last
            lines << create(self) { line(v, vertices[i+1]) }
          end
        end
        lines.flatten
      end
    end
  end
end
