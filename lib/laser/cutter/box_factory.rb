# frozen_string_literal: true

module Laser
  module Cutter
    # Picks the box a configuration asks for, so a renderer need not know
    # how many kinds there are.
    module BoxFactory
      # @param config [Configuration]
      # @return [Box, Sloped::Box] a sloped box when the configuration has a slope
      def self.for(config)
        config[:slope] ? Sloped::Box.new(config) : Box.new(config)
      end
    end
  end
end
