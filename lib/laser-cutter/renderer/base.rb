module Laser
  module Cutter
    module Renderer
      # subject is what we are rendering
      # enclosure is the rectangle enclosing our subject's rendered image
      # page_manager contains access to units and page sizes
      class Base
        attr_accessor :config, :subject, :enclosure, :page_manager
        attr_accessor :color_dict

        def initialize(config, subject = nil, dict = Laser::Cutter::Helpers::Colors)
          self.config = config
          self.subject = subject
          self.color_dict = dict
          self.page_manager = Laser::Cutter::PageManager.new(config.units)
        end

        def color(name)
          color_dict.const_get(name.to_s.upcase)
        rescue NameError
          STDERR.puts "Can't find color named #{name} in the dictionary #{color_dict.name}".red if config.debug || config.verbose
          '000000'
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

