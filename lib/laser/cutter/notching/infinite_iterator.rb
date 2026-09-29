# frozen_string_literal: true

module Laser
  module Cutter
    module Notching
      # Alternating iterator
      InfiniteIterator = Struct.new(:array) do
        attr_accessor :array, :next_index, :calls

        def initialize(array)
          self.array = array
          self.calls = 0
          self.next_index = 0
        end

        def next
          item = array[next_index].clone
          self.next_index += 1
          self.next_index %= array.size
          self.calls += 1
          item = yield item, calls if block_given?
          item
        end
      end
    end
  end
end
