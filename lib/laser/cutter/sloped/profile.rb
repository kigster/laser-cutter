# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # The side view of a box whose front slopes back: the inside outline of
      # a side wall, and the lengths of the panels that close it.
      #
      # Seen from the left, front to the left, the outline runs
      #
      #             top (Dt)
      #           +--------+
      #          /         |
      #  tilted /          |
      #        /           | back (H)
      #       +            |
      # front |            |
      #  (Hf) +------------+
      #          bottom (D)
      #
      # Every length is of the inside outline, in the box's units. The tilted
      # panel rises at +slope+ degrees, so the top strip is whatever depth is
      # left: Dt = D - (H - Hf) / tan(slope). A strip of zero size is dropped.
      #
      # Where the tilted panel meets a strip, the corner is obtuse and the
      # joint is a plain butt joint: the strip runs past the corner over the
      # end of the tilted panel, and the tilted panel stops short of it, so
      # their outside faces meet with no gap and no overlap. Where it meets
      # the back or the bottom directly, the corner is acute, and both panels
      # simply end at the corner.
      class Profile
        # @return [Float] depth, height, front height, and the thickness of the material
        attr_reader :depth, :height, :front_height, :thickness

        # @return [Float] the angle of the tilted panel above horizontal, in radians
        attr_reader :angle

        # @param depth [Numeric] D, the inside depth of the box
        # @param height [Numeric] H, the inside height at the back
        # @param front_height [Numeric] Hf, the inside height at the front
        # @param slope [Numeric] the angle of the tilted panel, in degrees
        # @param thickness [Numeric] of the material
        # @raise [InvalidOption] when the numbers do not make this shape
        def initialize(depth:, height:, front_height:, slope:, thickness:)
          @depth = depth.to_f
          @height = height.to_f
          @front_height = front_height.to_f
          @thickness = thickness.to_f
          @slope = slope.to_f
          validate!
          @angle = @slope * Math::PI / 180
          compute_lengths!
          freeze
        end

        # @return [Float] Dt, the inside depth of the top strip
        attr_reader :top_depth

        # @return [Float] S, the inside length of the slope, corner to corner
        attr_reader :slope_length

        # Whether the box has a top strip, and a front strip.
        def top_strip? = top_depth.positive?
        def front_strip? = front_height.positive?

        # The inside outline, counter-clockwise from the front of the bottom.
        #
        # @return [Array<Geometry::Point>] five corners; four when one strip is dropped,
        #   and three, a wedge, when both are
        def vertices
          points = [[0, 0], [depth, 0], [depth, height]]
          points << [depth - top_depth, height] if top_strip?
          points << [0, front_height] if front_strip?
          points.map { |x, y| Geometry::Point[x, y] }
        end

        # The part of the slope the tilted panel covers, and so the part of a
        # side wall's sloped edge that is notched.
        #
        # @return [Geometry::Line] from its low end to its high end
        def tilted_span
          low = slope_low.plus(direction * front_cut)
          high = slope_high.plus(direction * -top_cut)
          Geometry::Line.new(low, high)
        end

        # The outside face of the tilted panel, one thickness out from its span.
        #
        # @return [Geometry::Line] from its low end to its high end
        def tilted_outside
          out = Vector[-Math.sin(angle), Math.cos(angle)] * thickness
          span = tilted_span
          Geometry::Line.new(span.p1.plus(out), span.p2.plus(out))
        end

        # @return [Float] the length of the tilted panel, end to end
        def tilted_length = slope_length - front_cut - top_cut

        # @return [Float] the length of the top strip, front to back; 0 when it is dropped
        def top_strip_length = top_strip? ? top_depth + (thickness / Math.sin(angle)) : 0.0

        # @return [Float] the height of the front strip; 0 when it is dropped
        def front_strip_length = front_strip? ? front_height + (thickness / Math.cos(angle)) : 0.0

        private

        attr_reader :slope

        def validate!
          { depth: depth, height: height, thickness: thickness }.each do |name, value|
            raise InvalidOption, "#{name} must be above zero, got #{value}" unless value.positive?
          end
          raise InvalidOption, "slope must be between 0 and 90 degrees, got #{slope}" unless slope.positive? && slope < 90
          raise InvalidOption, "front height must be at least zero, got #{front_height}" if front_height.negative?
          return if front_height < height

          raise InvalidOption, "front height (#{front_height}) must be below the height (#{height})"
        end

        def compute_lengths!
          run = (height - front_height) / Math.tan(angle)
          if run > depth + Geometry::Tuple::PRECISION
            raise InvalidOption,
                  "a #{slope}° slope from #{front_height} up to #{height} needs a depth of #{run.round(3)}, " \
                  "but the depth is #{depth}; raise the slope or the front height"
          end

          @top_depth = [depth - run, 0.0].max
          @top_depth = 0.0 if @top_depth < Geometry::Tuple::PRECISION
          @slope_length = Math.hypot(run, height - front_height)
          refuse_no_tilted_panel!
        end

        # Under a strip the tilted panel stops short of the corner: by more at
        # the front the steeper the slope, and by more at the top the shallower.
        # A slope too short for both cuts leaves none of the panel. Between two
        # strips that is when the front strip, Hf + t / cos(slope), reaches the
        # height, so a lower front always helps and a different slope may not.
        def refuse_no_tilted_panel!
          return if tilted_length > Geometry::Tuple::PRECISION

          raise InvalidOption,
                "a #{slope}° slope from a front height of #{front_height} leaves no tilted panel in material " \
                "#{thickness} thick: the strips take #{(front_cut + top_cut).round(3)} of a slope " \
                "#{slope_length.round(3)} long; lower the front height"
        end

        def slope_low = Geometry::Point[0, front_height]
        def slope_high = Geometry::Point[depth - top_depth, height]
        def direction = Vector[Math.cos(angle), Math.sin(angle)]

        # How far the tilted panel stops short of each corner, under a strip.
        def top_cut = top_strip? ? thickness / Math.tan(angle) : 0.0
        def front_cut = front_strip? ? thickness * Math.tan(angle) : 0.0
      end
    end
  end
end
