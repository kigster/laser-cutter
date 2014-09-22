module Laser
  module Cutter
    module Geometry
      class Tuple
        attr_accessor :coords
        PRECISION = 0.000001

        def initialize(*args)
          args = customize_args(args)
          x = args.first
          if x.is_a?(String)
            parse_string(x)
          elsif x.is_a?(Hash)
            parse_hash(x)
          elsif x.is_a?(Array)
            self.coords = x.clone
          else
            self.coords = args.clone
          end

          self.coords.map!(&:to_f)
        end

        def customize_args(args)
          args
        end

        def separator
          raise NotImplementedError
          # 'x'
        end

        def hash_keys
          raise NotImplementedError
          # [:x, :y, :z] or [:h, :w, :d]
        end

        def to_a
          self.coords
        end

        def to_s
          "{#{coords.map { |a| sprintf("%.5f", a) }.join(separator)}}"
        end

        def valid?
          raise "Have nil value: #{self.inspect}" if coords.any? { |c| c.nil? }
          true
        end

        def eql?(other)
          return false unless other.respond_to?(:coords)
          equal = true
          self.coords.each_with_index do |c, i|
            if (c - other.coords[i])**2 > PRECISION
              equal = false
              break
            end
          end
          equal
        end

        def clone
          clone = super
          clone.coords = self.coords.clone
          clone
        end

        private

        #
        # convert from, eg "100,50" to [100.0, 50.0],
        # and then to a new instance.
        #
        def parse_string string
          self.coords = string.split(separator).map(&:to_f)
        end

        def parse_hash hash
          self.coords = []
          hash_keys.each { |k| self.coords << hash[k] }
        end

      end


    end
  end
end
