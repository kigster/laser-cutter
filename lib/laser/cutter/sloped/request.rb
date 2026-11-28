# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # Checks that settings which ask for a sloped box can be drawn, before
      # anything is. Settings with neither a slope nor a front height ask for
      # the box with six panels, and pass.
      module Request
        # @param settings [Hash, Configuration] slope, front_height, lid, depth, height and thickness, by Symbol
        # @return [Profile, nil] the side view of the sloped box; nil when the settings ask for none
        # @raise [MissingOption] for a slope without a front height
        # @raise [InvalidOption] for a front height without a slope, a lid a sloped box
        #   cannot have, or numbers that do not make the shape
        def self.validate!(settings)
          slope, front_height = settings.values_at(:slope, :front_height)
          return if slope.nil? && front_height.nil?
          raise InvalidOption, 'front_height is the front of a sloped box, so it needs a slope.' if slope.nil?
          raise MissingOption, 'front_height is required with slope, but missing.' if front_height.nil?

          lid = (settings[:lid] || Box::LIDS.first).to_sym
          unless Box::LIDS.include?(lid)
            raise InvalidOption, "lid cannot be #{lid.to_s.inspect} with a slope, but must be one of: #{Box::LIDS.join(', ')}."
          end

          Profile.new(**settings.to_h.slice(:depth, :height, :thickness), front_height: front_height, slope: slope)
        end
      end
    end
  end
end
