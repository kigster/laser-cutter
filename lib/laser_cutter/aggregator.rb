# frozen_string_literal: true

module Laser
  module Cutter
    class Aggregator
      attr_accessor :lines

      def initialize(array_of_lines = [])
        self.lines = array_of_lines.sort
      end

      # This method finds lines that are identical (same p1/p2)
      def dedup!
        lines_to_delete = []
        count = lines.size
        (0..(count - 1)).each do |i|
          ((i + 1)..(count - 1)).each do |j|
            l1 = lines[i]
            l2 = lines[j]
            if l1.eql?(l2)
              lines_to_delete << l1
              lines_to_delete << l2
            end
          end
        end
        self.lines = lines - lines_to_delete
        self
      end

      # Find overlapping (intersecting) sections of lines and
      # remove them.
      def deoverlap!
        lines_to_delete = []
        lines_to_add = []
        count = lines.size
        (0..(count - 1)).each { |i|
          ((i + 1)..(count - 1)).each { |j|
            l1 = lines[i]
            l2 = lines[j]
            next unless l1.overlaps?(l2)

            lines_to_delete << l1
            lines_to_delete << l2
            lines_to_add << l1.xor(l2)
          }
        }

        lines_to_delete.uniq!
        lines_to_delete.flatten!
        lines_to_add.uniq!
        lines_to_add.flatten!

        self.lines = (lines - lines_to_delete + lines_to_add).flatten
        lines.sort!
        self
      end
    end
  end
end
