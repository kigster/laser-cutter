# frozen_string_literal: true

module Laser
  module Cutter
    module Notching
      class Base
        attr_accessor :edge

        def initialize(edge)
          @edge = edge
        end

        def notches
          raise 'Abstract method'
        end
      end
    end
  end
end
