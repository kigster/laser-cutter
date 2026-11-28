# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # Which panel fills the corner cube at each square corner of the box.
      #
      # Three panels meet at such a corner and one of them carries the cube,
      # as a square on its own corner. The side wall never does. Of the other
      # two, the back and the front strip come first, as the front and back
      # do in the box with six panels. A panel whose two notches next to the
      # corner are both holes cannot carry it, since the square would hang
      # off the panel by a single point; the other panel then begins with a
      # tab there, and takes it.
      class Corners
        # @param profile [Profile]
        # @param width [Numeric] the inside width of the box
        # @param notcher [Notcher]
        def initialize(profile:, width:, notcher:)
          @profile = profile
          @width = width
          @notcher = notcher
          freeze
        end

        # @return [Symbol, nil] :front or :bottom; nil without a front strip, where the corner is not square
        def front_bottom
          return unless @profile.front_strip?

          carries?(@profile.front_height) ? :front : :bottom
        end

        # @return [Symbol] :back or :bottom
        def bottom_back
          carries?(@profile.height) ? :back : :bottom
        end

        # @return [Symbol, nil] :back or :top; nil without a top strip, where the corner is not square
        def back_top
          return unless @profile.top_strip?

          carries?(@profile.height) ? :back : :top
        end

        private

        # Whether a panel with its middle notches out, as wide as the box and
        # with ends of the given length, begins with a tab on either edge.
        def carries?(end_length)
          [@width, end_length].any? { |length| @notcher.tab_first?(length, center_out: true) }
        end
      end
    end
  end
end
