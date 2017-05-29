module LaserCutter
  module Strategy
    class LineJoiner
      # This class is an algorithm that takes in a set of lines that are supposed
      # to form a fully connected shape, but may not be ordered. It then organizes
      # the lines in a way that the next line starts at the end of the previous line.
      # This allows PDF drawing to use #line_to method, allowing the lines to be generated
      # in a joint fashion, and appear as a single "group" inner of an editing software,
      # such as Adobe® Illustrator™, which, obviously, is © 2016 Adobe, Inc. ROFL.
      #
      # The algorithm may throw a +NonContiguousPolygonError+ in case not all lines have
      # a corresponding pair.
      #
      # == Example
      #
      # ```ruby
      # module Laser
      #   module Cutter
      #     def join(lines = [])
      #       LineJoiner.new(lines).join
      # ````
      #
      class NonContiguousPolygonError < StandardError;
      end
      attr_accessor :lines, :joined_lines, :disjoint_lines

      def initialize(lines)
        self.lines = lines.dup.sort.delete_if { |l| l.p1.eql?(l.p2) }
      end

      # This method can be called safely multiple times. It creates
      # a copy of #lines in #disjoint_lines, and one by one moves them into
      # the #joined_lines. If successful, #disjoint_lines should be empty
      # in the end.
      def join
        self.disjoint_lines = self.lines.dup # make a copy
        self.joined_lines   = []
        self.joined_lines << disjoint_lines.shift
        while !disjoint_lines.empty?
          # moves one line from #disjoint_lines to #joined_lines or throws
          # an exception if not found.
          find_next_line
        end
        self.lines = joined_lines
      end

      private

      def find_next_line
        last = joined_lines.last
        disjoint_lines.each do |line|
          if last.p2.eql?(line.p1) or last.p2.eql?(line.p2)
            joined_lines << line
            break
          end
        end

        # if +last+ is the same as the last line in +joined_lines+,
        # it means that we did not add any new lines :(
        check_if_contiguous(last)

        # and if we are still here, that means we found a contiguous line, so
        # let's add it!
        disjoint_lines.delete(joined_lines.last)
      end

      def check_if_contiguous(last)
        if last == joined_lines.last
          error = <<-eof
                Non-contiguous range: line\n\n\t+
                #{last}\n\n +
                 –– has no pair in the set:\n\n +
                #{lines.map(&:to_s).join("\n\t")}
          eof
          error.gsub!(/\n(\s+)/, "\n")
          raise NonContiguousPolygonError.new(error)
        end
      end
    end
  end
end
