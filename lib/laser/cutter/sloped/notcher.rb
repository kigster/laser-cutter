# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # Draws the notched path between two points of a panel, and says how it
      # begins. Every panel of the sloped box is walked counter-clockwise, so
      # the material a path notches into always lies to its right.
      #
      # Paths are drawn without kerf: a panel is grown by half the kerf once
      # its outline is whole.
      class Notcher
        # @return [Float] the thickness of the material
        attr_reader :thickness

        # @param notch_width [Numeric] the notch length asked for, a guide only
        # @param thickness [Numeric] of the material
        def initialize(notch_width:, thickness:)
          @notch_width = notch_width.to_f
          @thickness = thickness.to_f
          freeze
        end

        # @param from [Geometry::Point] a corner of the inside outline
        # @param to [Geometry::Point] the next corner
        # @param center_out [Boolean] whether the middle notch is a tab
        # @return [Array<Geometry::Point>] the path, from the one corner to the other
        def path(from, to, center_out:)
          lines = edge(from, to, center_out).lines
          lines.map(&:p1) << lines.last.p2
        end

        # @param length [Numeric] of a side
        # @param center_out [Boolean] whether its middle notch is a tab
        # @return [Boolean] whether the side begins, and so ends, with a tab
        def tab_first?(length, center_out:)
          edge(Geometry::Point[0, 0], Geometry::Point[length, 0], center_out).first_notch_out?
        end

        private

        def edge(from, to, center_out)
          Notching::AngledEdge.new(from, to, outward: :right, notch_width: @notch_width, thickness: thickness,
                                             kerf: 0.0, center_out: center_out)
        end
      end
    end
  end
end
