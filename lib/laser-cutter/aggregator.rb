module Laser
  module Cutter
    class Aggregator
      attr_accessor :lines

      def initialize(array_of_lines = [])
        self.lines = array_of_lines.sort
      end

      def dedup
        new_list = []
        lines.sort.each_with_index do |e, i|
          next if i < (lines.size - 1) && e.eql?(lines[i + 1])
          next if i > 0 && e.eql?(lines[i - 1])
          new_list << e
        end
        new_list
      end

    end
  end
end
