# frozen_string_literal: true

module Laser
  module Cutter
    module Sloped
      # A box whose front slopes back, drawn as seven panels. It answers what
      # the renderers ask of a Box: the lines to cut, the rectangle that
      # encloses them, and room for the metadata.
      #
      # The panels come from Panels, each in its own frame and without kerf.
      # Here each one is grown by half the kerf, so it is cut to size, and
      # moved to its place on the sheet.
      class Box
        # How the tilted panel joins the side walls: notched into both, or lying on them.
        LIDS = %i[full plain].freeze

        # @return [Profile] the side view of the box
        attr_reader :profile

        # @return [Geometry::Point] the size of the metadata block the layout keeps clear
        attr_reader :metadata

        # @param config [Configuration, Hash] width, height, depth, front_height, slope, thickness, and
        #   optionally notch, kerf, padding and lid
        # @raise [InvalidOption] when the numbers do not make this shape
        def initialize(config)
          @config = config
          @profile = Profile.new(depth: config[:depth], height: config[:height], front_height: config[:front_height],
                                 slope: config[:slope], thickness: config[:thickness])
          @metadata = Geometry::Point[0, 0]
        end

        # Moves every panel clear of a metadata block of the given size.
        #
        # @param size [Geometry::Point]
        def metadata=(size)
          @metadata = size
          @outlines = @enclosure = nil
        end

        # @return [Hash{String => Array<Geometry::Line>}] the lines to cut for each panel, by its name
        def outlines
          @outlines ||= begin
            placements = layout.placements
            panels.to_h.to_h do |name, loop|
              [name, loop.map { |point| placements[name].apply(point) }.grow(kerf / 2.0).lines]
            end
          end
        end

        # @return [Array<Geometry::Line>] every line to cut
        def generate_notches
          outlines.values.flatten
        end
        alias notches generate_notches

        # @return [Geometry::Rect] the smallest rectangle around every line
        def enclosure
          @enclosure ||= begin
            points = generate_notches.flat_map { |line| [line.p1, line.p2] }
            xs = points.map(&:x)
            ys = points.map(&:y)
            Geometry::Rect[Geometry::Point[xs.min, ys.min], Geometry::Point[xs.max, ys.max]]
          end
        end

        private

        def kerf = (@config[:kerf] || 0.0).to_f

        def lid = (@config[:lid] || LIDS.first).to_sym

        def panels
          notcher = Notcher.new(notch_width: @config[:notch] || (3 * profile.thickness), thickness: profile.thickness)
          Panels.new(profile: profile, width: @config[:width], notcher: notcher, lid: lid)
        end

        def layout
          Layout.new(sizes: panels.sizes, thickness: profile.thickness, padding: @config[:padding] || 0.0, metadata: metadata)
        end
      end
    end
  end
end
