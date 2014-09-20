module Laser
  module Cutter
    class Coordinate < Struct.new(:x, :y)

      def to_a
        [self.x, self.y]
      end

      def to_s
        "#{sprintf "%3d", x}(x),#{sprintf "%3d", y}(y)"
      end
    end


  end
end
