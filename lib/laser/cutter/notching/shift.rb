# frozen_string_literal: true

module Laser
  module Cutter
    module Notching
      Shift = Struct.new(:delta, :direction, :dim_index) do
        def next_point_after(point)
          p = point.clone
          shift = []
          shift[dim_index] = delta * direction
          shift[(dim_index + 1) % 2] = 0
          p.plus(*shift)
        end
      end
    end
  end
end
