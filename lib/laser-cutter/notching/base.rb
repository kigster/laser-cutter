module Laser::Cutter::Notching
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
