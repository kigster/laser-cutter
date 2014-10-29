require_relative 'notched_path'

module Laser
  module Cutter
    module Notching
      class Shift < Struct.new(:delta, :direction, :dim_index)
        def next_point_after point
          p = point.clone
          shift = []
          shift[dim_index]           = delta * direction
          shift[(dim_index + 1) % 2] = 0
          p.plus *shift
        end
      end

      # Alternating iterator
      class InfiniteIterator < Struct.new(:array)
        attr_accessor :array, :next_index, :calls
        def initialize(array)
          self.array = array
          self.calls = 0
          self.next_index = 0
        end

        def next
          item = self.array[next_index].clone
          self.next_index += 1
          self.next_index %= array.size
          self.calls += 1
          item = yield item, self.calls if block_given?
          item
        end
      end

      class PathGenerator

        extend Forwardable
        %i(center_out thickness corners kerf kerf? notch_width corners).each do |method_name|
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
          shifts = define_shifts
          vertices = []
          path = NotchedPath.new

          if corners
            # path.corner_boxes = corner_boxes if corners
            sides = corner_boxes.map(&:sides).flatten
            sides.each do |s|
              unless s.p1.coords.[](dimension_along) == edge.inside.p1.coords.[](dimension_along) &&
                     s.p2.coords.[](dimension_along) == edge.inside.p2.coords.[](dimension_along)
                  path.lines << s
              end
            end
          end

          point = starting_point

          vertices << point
          adjust_for_kerf(vertices,-1)
          shifts.each do |shift|
            point = shift.next_point_after point
            vertices << point
          end
          adjust_for_kerf(vertices, 1)
          path.vertices = vertices
          path
        end

        def adjust_for_kerf(vertices, direction)
          if kerf?
            point = vertices.pop
            point = corners ? point.plus(2 * direction * shift_vector(1)) : point
            vertices << point
          end
        end

        def corner_boxes
          r1 = Geometry::Rect[edge.inside.p1.clone, edge.outside.p1.clone]
          r2 = Geometry::Rect[edge.inside.p2.clone, edge.outside.p2.clone]

          if kerf?
            v1 = shift_vector(1)
            v2 = shift_vector(2)
            k = -1
            unless first_notch_out?
              k = -2
            end
            r1 = Geometry::Rect[edge.inside.p1.plus(k * v1), edge.outside.p1.clone]
            r2 = Geometry::Rect[edge.inside.p2.plus(k * v2), edge.outside.p2.clone]
          end
          # relocate returns the object
          [r1, r2].map(&:relocate!)
        end

        def shift_vector(index)
          shift = []
          shift[dimension_across] = 0
          shift[dimension_along] = kerf / 2.0 * edge.send("v#{index}".to_sym).[](dimension_along)
          Vector.[](*shift)
        end

        # True if the first notch should be a tab (sticking out), or false if it's a hole.
        def first_notch_out?
          edge.add_across_line?(center_out)
        end

        def starting_point
          edge.inside.p1.clone # start
        end

        # 0 = X, 1 = Y
        def dimension_along
          (edge.inside.p1.x == edge.inside.p2.x) ? 1 : 0
        end
        def dimension_across
          (dimension_along + 1) % 2
        end
        def direction_along
          (edge.inside.p1.coords.[](dimension_along) < edge.inside.p2.coords.[](dimension_along)) ? 1 : -1
        end
        def direction_across
          (edge.inside.p1.coords.[](dimension_across) < edge.outside.p1.coords.[](dimension_across)) ? 1 : -1
        end

        private

        # This method has the bulk of the logic: we create the list of path deltas
        # to be applied when we walk the edge next.
        # @param [Object] shift
        def define_shifts
          along_iter = create_iterator_along
          across_iter = create_iterator_across

          shifts = []
          inner = true  # false when we are drawing outer notch, true when inner

          if first_notch_out?
            shifts << across_iter.next
            inner = !inner
          end

          (1..edge.notch_count).to_a.each do |notch_number|
            shifts << along_iter.next do |shift, index|
              if inner && (notch_number > 1 && notch_number < edge.notch_count)
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
          InfiniteIterator.new([ Shift.new(notch_width, direction_along, dimension_along)])
        end

        def create_iterator_across
          InfiniteIterator.new([ Shift.new(thickness,  direction_across, dimension_across),
                                 Shift.new(thickness, -direction_across, dimension_across)])
        end
      end
    end
  end
end
