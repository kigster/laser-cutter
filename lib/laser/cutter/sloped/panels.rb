# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # The panels of a sloped box, each drawn in its own frame and without
      # kerf: two side walls, the bottom, the back, the tilted panel, and the
      # top and front strips when the box has them.
      #
      # Along every joint the two panels that meet take opposite middle
      # notches, so they interlock. A side wall takes a hole everywhere; the
      # back and the front strip take a tab on every edge; the bottom and the
      # top strip take a tab into the side walls and a hole into the back and
      # the front strip.
      class Panels
        # The names of the panels, in the order they are drawn.
        NAMES = %w[left right bottom back top tilted front].freeze

        # @param profile [Profile]
        # @param width [Numeric] the inside width of the box
        # @param notcher [Notcher]
        # @param lid [Symbol] :full or :plain, how the tilted panel joins the side walls
        def initialize(profile:, width:, notcher:, lid:)
          @profile = profile
          @width = width.to_f
          @notcher = notcher
          @lid = lid
          @corners = Corners.new(profile: profile, width: width, notcher: notcher)
          freeze
        end

        # @return [Hash{String => Geometry::Loop}] the outline of each panel the box has, by name
        def to_h
          side = SidePanel.new(profile: @profile, notcher: @notcher, lid: @lid).loop
          { 'left' => side, 'right' => side, 'bottom' => bottom, 'back' => back,
            'top' => top, 'tilted' => tilted, 'front' => front }.compact
        end

        # The inside size of each panel, which is what a Placement flips it within.
        #
        # @return [Hash{String => Array(Float, Float)}] width and length of each panel the box has, by name
        def sizes
          side = [@profile.depth, @profile.height]
          { 'left' => side, 'right' => side, 'bottom' => [@width, @profile.depth], 'back' => [@width, @profile.height],
            'top' => strip(@profile.top_strip_length), 'tilted' => [@width, @profile.tilted_length],
            'front' => strip(@profile.front_strip_length) }.compact
        end

        private

        def strip(length)
          [@width, length] if length.positive?
        end

        def panel(length:, joint: length, **)
          RingPanel.new(notcher: @notcher, width: @width, length: length, joint: joint, **).loop
        end

        # Near the front, far at the back.
        def bottom
          panel(length: @profile.depth, near: (false if @profile.front_strip?), far: false,
                corners: carried(near: @corners.front_bottom, far: @corners.bottom_back, by: :bottom))
        end

        # Near the bottom, far at the top.
        def back
          panel(length: @profile.height, near: true, far: (true if @profile.top_strip?),
                corners: carried(near: @corners.bottom_back, far: @corners.back_top, by: :back))
        end

        # Near the back, far over the end of the tilted panel.
        def top
          return unless @profile.top_strip?

          panel(length: @profile.top_strip_length, joint: @profile.top_depth, near: false,
                corners: carried(near: @corners.back_top, by: :top))
        end

        # Near the bottom, far over the end of the tilted panel.
        def front
          return unless @profile.front_strip?

          panel(length: @profile.front_strip_length, joint: @profile.front_height, near: true,
                corners: carried(near: @corners.front_bottom, by: :front))
        end

        # Notched into the side walls end to end, or lying on them.
        def tilted
          panel(length: @profile.tilted_length, joint: @lid == :plain ? 0.0 : @profile.tilted_length)
        end

        # The edges whose corners a panel carries.
        def carried(by:, near: nil, far: nil)
          { near: near, far: far }.select { |_edge, owner| owner == by }.keys
        end
      end
    end
  end
end
