module Laser
  module Cutter
    module Notching
      class NoSuchStrategyError< StandardError; end
      class DefaultNotchStrategy
        attr_accessor :config

        def initialize(config)
          self.config = config
        end

        def strategy(name)
          self.send(name.to_sym)
        rescue NameError => e
          puts e.inspect
          puts e.backtrace.join("\n")
          raise NoSuchStrategyError.new("Can't find strategy #{name}")
        end

        def self.strategies
          (self.new({}).private_methods - Object.new.private_methods).grep /^from_/
        end

        private

        def from_sides
          config.longest_side / 5
        end

        def from_thickness
          (config[:thickness] * 3.0).round(5)
        end

      end
    end
  end
end
