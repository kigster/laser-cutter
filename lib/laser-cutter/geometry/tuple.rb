module Laser
  module Cutter
    module Geometry
      class Tuple
        attr_accessor :coordinates

        def initialize(*args)
          x = args.first
          if x.is_a?(String)
            parse_string(x)
          elsif x.is_a?(Hash)
            parse_hash(x)
          else
            self.coordinates = args
          end

          self.coordinates.map!(&:to_f)
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
          self.coordinates
        end

        def to_s
          "#{self.class.name}:#{coordinates.map { |a| sprintf("%3f", a) }.join(separator)}"
        end

        def valid?
          raise "Have nil value: #{self.inspect}" if coordinates.any? { |c| c.nil? }
          true
        end

        def eql?(other)
          return false unless other.respond_to?(:coordinates)
          self.coordinates.eql?(other.coordinates)
        end

        private

        #
        # convert from, eg "100,50" to [100.0, 50.0],
        # and then to a new instance.
        #
        def parse_string string
          self.coordinates = string.split(separator).map(&:to_f)
        end

        def parse_hash hash
          self.coordinates = []
          hash_keys.each { |k| self.coordinates << hash[k] }
        end

      end


    end
  end
end
