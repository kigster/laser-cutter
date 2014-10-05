module Laser
  module Cutter
    module Renderer
      # subject is what we are rendering
      # enclosure is the rectangle enclosing our subject's rendered image
      # page_manager contains access to units and page sizes
      class Base
        BLACK = "000000"
        BLUE = "0070E0"

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

