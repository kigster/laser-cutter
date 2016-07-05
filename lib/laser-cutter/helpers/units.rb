module Laser
  module Cutter
    module Helpers
      class Units
        MM2IN = ->(v) { 0.039370079 * v }
        IN2MM = ->(v) { 25.4 * v }
        module Transformation
          def from
            self
          end

          def inches(value)
            IN2MM.call(value)
          end

          def millimeters(value)
            MM2IN.call(value)
          end
        end

        extend Transformation
      end
    end
  end
end
