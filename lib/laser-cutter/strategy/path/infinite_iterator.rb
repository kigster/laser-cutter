module Laser
  module Cutter
    module Strategy
      module Path
        # Alternating iterator
        class InfiniteIterator < Struct.new(:array)
          attr_accessor :array, :next_index, :calls

          def initialize(array)
            self.array      = array
            self.calls      = 0
            self.next_index = 0
          end

          def next
            item            = self.array[next_index].clone
            self.next_index += 1
            self.next_index %= array.size
            self.calls      += 1
            item            = yield item, self.calls if block_given?
            item
          end
        end
      end
    end
  end
end
