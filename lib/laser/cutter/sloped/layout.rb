# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # Lays the panels of a sloped box on the sheet, unfolded: the panels
      # that wrap around the box in one column, in the order they wrap, and a
      # side wall either side of the back.
      #
      #              +---------+
      #              |  front  |
      #              +---------+
      #              | tilted  |
      #              +---------+
      #              |   top   |
      #   +-------+  +---------+  +-------+
      #   | left  |  |  back   |  | right |
      #   +-------+  X---------+  +-------+
      #              +---------+
      #              | bottom  |
      #              +---------+
      #   0,0
      #
      # Edges that face each other on the sheet meet on the box. The front
      # strip is turned half way round, so the edge it shares with the tilted
      # panel faces that panel, and the right wall is the mirror image of the
      # left. The corner at the bottom left is kept free for the metadata.
      class Layout
        # @param sizes [Hash{String => Array(Float, Float)}] the inside width and length of each panel, see Panels#sizes
        # @param thickness [Numeric] of the material, which a notched edge reaches past its panel by
        # @param padding [Numeric] the space between two panels
        # @param metadata [Geometry::Point] the size of the block to keep free at the bottom left
        def initialize(sizes:, thickness:, padding:, metadata:)
          @sizes = sizes
          @thickness = thickness.to_f
          @padding = padding.to_f
          @metadata = metadata
          freeze
        end

        # @return [Hash{String => Placement}] where each panel goes, by name
        def placements
          wall = 2 * @thickness
          x, y = origin
          depth = @sizes['left'][0]
          placed = {
            'left'   => place('left', x - depth - wall - @padding, y),
            'right'  => place('right', x + @sizes['back'][0] + wall + @padding, y, flip_x: true),
            'bottom' => place('bottom', x, y - @sizes['bottom'][1] - wall - @padding),
            'back'   => place('back', x, y)
          }
          placed.merge(column(x, y + @sizes['back'][1]))
        end

        private

        # The bottom left corner of the back, the X in the picture: clear of
        # the left wall and the bottom, and of the metadata block.
        def origin
          clear = @padding + @sizes['left'][0] + (3 * @thickness)
          [[clear, @metadata.x + (2 * @thickness) + @padding].max, [clear, @metadata.y + (2 * @thickness) + @padding].max]
        end

        # The panels above the back. A strip reaches a thickness towards the
        # panel it is notched into; the plain edges in between reach nowhere.
        def column(x, y)
          placed = {}
          if @sizes['top']
            y += (2 * @thickness) + @padding
            placed['top'] = place('top', x, y)
            y += @sizes['top'][1]
          end
          y += @padding
          placed['tilted'] = place('tilted', x, y)
          placed['front'] = place('front', x, y + @sizes['tilted'][1] + @padding, flip_x: true, flip_y: true) if @sizes['front']
          placed
        end

        def place(name, x, y, **flips)
          Placement.new(Geometry::Point[x, y], size: @sizes[name], **flips)
        end
      end
    end
  end
end
