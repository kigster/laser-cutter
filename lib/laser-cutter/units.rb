module Laser
  module Cutter
    class Units
      MM2IN = ->(v) { 0.039370079 * v }
      IN2MM = ->(v) { 25.4 * v }

      Converter = {
        in: IN2MM,
        mm: MM2IN
      }
    end
  end
end
