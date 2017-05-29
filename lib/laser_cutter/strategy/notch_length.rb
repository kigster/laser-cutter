require 'active_support/inflector'
module LaserCutter
  module Strategy
    class NoSuchStrategyError < StandardError
    end

    module NotchLength
      class Base
        # TODO: is this needed?
        @subclasses = {}
        class << self
          attr_accessor :subclasses
        end

        def self.inherited(clazz)
          self.subclasses[clazz.name.demodulize] = clazz
        end

        attr_accessor :config

        def initialize(config)
          self.config = config
          self
        end
      end

      class FromSides < Base
        def len
          config.longest_side / 5
        end
      end

      class FromThickness < Base
        def len
          (config[:thickness] * 3.0).round(5)
        end
      end
    end
  end
end
