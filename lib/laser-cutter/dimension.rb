module Laser
  module Cutter
    class Dimension < Struct.new(:width, :height, :depth)
      def valid?
        raise "Something is nil: #{self.inspect}" if (self.width.nil? or self.height.nil? or self.depth.nil?)
        true
      end

    end
  end
end
