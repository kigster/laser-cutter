module Laser
  module Cutter
    module Renderer
      class Base
        BLACK = "000000"
        BLUE = "4090E0"

        attr_accessor :config, :subject, :enclosure, :page_manager

        def initialize(config, subject = nil)
          self.config = config
          self.subject = subject
          self.page_manager = Laser::Cutter::PageManager.new(config.units)
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

