require 'matrix'
module LaserCutter
  module Geometry
    class Tuple
      attr_accessor :coords
      PRECISION = 0.00001

      def initialize(*args)
        x           = args.first
        coordinates = if x.is_a?(String)
                        parse_string(x)
                      elsif x.is_a?(Hash)
                        parse_hash(x)
                      elsif x.is_a?(Array)
                        x.clone
                      elsif x.is_a?(Tuple) or x.is_a?(Vector)
                        x.to_a
                      else
                        args.clone
                      end
        coordinates.map!(&:to_f)
        self.coords = Vector.[](*coordinates)
      end

      def +(x, y = nil)
        shift = if x.is_a?(Vector)
                  x
                elsif x.is_a?(Tuple)
                  x.coords
                elsif y
                  Vector.[](x, y)
                end
        self.class.new(self.coords + shift)
      end


      alias_method :plus, :+

      def to_a
        self.coords.to_a
      end

      def to_s
        "[#{coords.to_a.map { |a| sprintf('%8.6f', a) }.join(separator)}]"
      end

      def valid?
        raise "Have nil value: #{self.inspect}" if coords.to_a.any? { |c| c.nil? }
        true
      end

      def x= value
        self.coords = Vector.[](value, coords.[](1))
      end

      def y= value
        self.coords = Vector.[](coords.[](0), value)
      end

      def x
        coords.[](0)
      end

      def y
        coords.[](1)
      end

      def separator
        ', '
      end

      def [] value
        coords.[](value)
      end

      # Override in subclasses, eg:
      # def separator
      #   ';'
      # end
      #
      # def hash_keys
      #   [:x, :y, :z] or [:h, :w, :d]
      # end
      def hash_keys
        [:x, :y]
      end

      # Identity, cloning and sorting/ordering
      def eql?(other)
        return false unless other.respond_to?(:coords)
        equal   = true
        coords1 = self.coords.to_a
        coords2 = other.coords.to_a

        coords1.each_with_index do |c, i|
          if (c - coords2[i]).abs > PRECISION
            equal = false
            break
          end
        end
        equal
      end

      def <=>(other)
        self.x == other.x ? self.y <=> other.y : self.x <=> other.x
      end

      def < (other)
        self.x == other.x ? self.y < other.y : self.x < other.x
      end

      def > (other)
        self.x == other.x ? self.y > other.y : self.x > other.x
      end

      def clone
        clone        = super
        clone.coords = self.coords.clone
        clone
      end

      private

      #
      # Convert from, eg "100,50" to [100.0, 50.0],
      def parse_string string
        string.split(separator).map(&:to_f)
      end

      # Return array of coordinates
      def parse_hash hash
        hash_keys.map { |k, v| hash[k] }
      end

    end


  end
end
