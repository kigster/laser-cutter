module Laser
  module Cutter
    module Renderer
      class Base
        BLACK = "000000"
        BLUE = "4090E0"

        attr_accessor :config, :subject, :enclosure
        def initialize(config = {}, subject)
          self.config = config
          self.subject = subject
        end

        def render
          raise 'Abstract method'
        end

        def units
          config.units.to_sym || :mm
        end
      end
    end
  end
end

