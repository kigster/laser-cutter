# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # A side wall of the sloped box: the profile, notched into every panel
      # that closes it.
      #
      # In its own frame x is the depth from the front and y the height, as
      # in Profile. Its square edges are notched into the bottom, the back and
      # the strips. Along the slope it is notched into the tilted panel, over
      # the span that panel covers, or left plain under a tilted panel that
      # lifts off.
      #
      # Where the tilted panel stops short under a strip, a wedge stays open
      # between its square end and the strip. The wall closes the end of that
      # wedge with a triangle, so nobody sees into the box from the side:
      #
      #        strip
      #   ----+=========
      #       |\  wedge
      #  end  | \
      #   of   \  \ slope
      #  tilted \
      class SidePanel
        # @param profile [Profile]
        # @param notcher [Notcher]
        # @param lid [Symbol] :full for a tilted panel notched into the wall, :plain for one lying on it
        def initialize(profile:, notcher:, lid:)
          @profile = profile
          @notcher = notcher
          @lid = lid
          freeze
        end

        # @return [Geometry::Loop] the outline, counter-clockwise from the front of the bottom
        def loop
          Geometry::Loop.new(bottom + back + top + slope + front)
        end

        private

        # The corners of the inside outline, see Profile#vertices.
        def corners = @profile.vertices

        def notched(from, to)
          @notcher.path(from, to, center_out: false)
        end

        def bottom = notched(corners[0], corners[1])

        def back = notched(corners[1], corners[2])

        # Along the top strip, then on under its end to the top of the wedge.
        def top
          return [] unless @profile.top_strip?

          notched(corners[2], corners[3]) << @profile.tilted_outside.p2
        end

        # Down the slope, over the span the tilted panel covers.
        def slope
          span = @profile.tilted_span
          @lid == :plain ? [span.p2, span.p1] : notched(span.p2, span.p1)
        end

        # From the top of the wedge under the front strip, down that strip.
        def front
          return [] unless @profile.front_strip?

          [@profile.tilted_outside.p1] + notched(corners.last, corners.first)
        end
      end
    end
  end
end
