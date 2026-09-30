# frozen_string_literal: true

module Laser
  module Cutter
    module Geometry
      class Tuple
        attr_accessor :coords

        PRECISION = 0.000001

        def initialize(*args)
          x = args.first
          coordinates = case x
                        when String
                          parse_string(x)
                        when Hash
                          parse_hash(x)
                        when Array
                          x.clone
                        when Tuple, Vector
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
          self.class.new(coords + shift)
        end

        alias_method :plus, :+

        def to_a
          coords.to_a
        end

        def to_s
          "{#{coords.to_a.map { |a| sprintf('%.5f', a) }.join(separator)}}"
        end

        def valid?
          raise "Have nil value: #{inspect}" if coords.to_a.any?(&:nil?)

          true
        end

        def x=(value)
          self.coords = Vector.[](value, coords.[](1))
        end

        def y=(value)
          self.coords = Vector.[](coords.[](0), value)
        end

        def x
          coords.[](0)
        end

        def y
          coords.[](1)
        end

        def separator
          ','
        end

        def [](value)
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

          equal = true
          coords.each_with_index do |c, i|
            if (c - other.coords.to_a[i])**2 > PRECISION
              equal = false
              break
            end
          end
          equal
        end

        def <=>(other)
          x == other.x ? y <=> other.y : x <=> other.x
        end

        def <(other)
          x == other.x ? y < other.y : x < other.x
        end

        def >(other)
          x == other.x ? y > other.y : x > other.x
        end

        def clone
          clone = super
          clone.coords = coords.clone
          clone
        end

        private

        #
        # Convert from, eg "100,50" to [100.0, 50.0],
        def parse_string(string)
          string.split(separator).map(&:to_f)
        end

        # Return array of coordinates
        def parse_hash(hash)
          hash_keys.map{ |k, _v| hash[k] }
        end
      end
    end
  end
end
