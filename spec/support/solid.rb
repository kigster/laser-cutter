# frozen_string_literal: true

# Stands the panels of a sloped box up in space, the way they are glued, and
# samples the material: a point that two panels both claim means they cannot
# be put together. It knows only where each panel goes, not how it was drawn.
#
# Space is x across the width, y back from the front, and z up, all from the
# inside corner at the front of the bottom on the left.
class Solid
  # Each panel's own frame: where a point in space falls on its outline, and
  # how deep it is in the material, counted from the inside face.
  FRAMES = {
    'left'   => ->(x, y, z, _box) { [y, z, -x] },
    'right'  => ->(x, y, z, box) { [y, z, x - box.width] },
    'bottom' => ->(x, y, z, _box) { [x, y, -z] },
    'back'   => ->(x, y, z, box) { [x, z, y - box.profile.depth] },
    'top'    => ->(x, y, z, box) { [x, box.profile.depth - y, z - box.profile.height] },
    'front'  => ->(x, y, z, _box) { [x, z, -y] },
    'tilted' => ->(x, y, z, box) { box.on_slope(x, y, z) }
  }.freeze

  # Sampling starts off the grid by a different amount on each axis, so no
  # sample lands on a face two panels share.
  OFFSETS = [0.31, 0.47, 0.59].freeze

  attr_reader :profile, :width

  # @param profile [Laser::Cutter::Sloped::Profile]
  # @param width [Float] the inside width of the box
  # @param outlines [Hash{String => Laser::Cutter::Geometry::Loop}] each panel in its own frame, by name
  def initialize(profile:, width:, outlines:)
    @profile = profile
    @width = width
    @polygons = outlines.transform_values { |outline| outline.points.map(&:to_a) }
    @low = profile.tilted_span.p1.to_a
    @cos = Math.cos(profile.angle)
    @sin = Math.sin(profile.angle)
  end

  # @param step [Float] the distance between samples
  # @return [Hash{String => Integer}] how many samples each pair of panels both claim, by "name+name"
  def collisions(step: profile.thickness / 2.0)
    xs, ys, zs = ranges(step)
    found = Hash.new(0)
    xs.each do |x|
      ys.each do |y|
        zs.each do |z|
          next if hollow?(x, y, z)

          owners = owners_of(x, y, z)
          found[owners.sort.join('+')] += 1 if owners.size > 1
        end
      end
    end
    found
  end

  # @return [Array<String>] the panels whose material holds a point
  def owners_of(x, y, z)
    @polygons.select do |name, polygon|
      u, v, depth = FRAMES.fetch(name).call(x, y, z, self)
      depth.positive? && depth < profile.thickness && inside?(polygon, u, v)
    end.keys
  end

  # A point in the frame of the tilted panel: along the slope from its low end, and out from its inside face.
  def on_slope(x, y, z)
    along = y - @low[0]
    up = z - @low[1]
    [x, (along * @cos) + (up * @sin), (up * @cos) - (along * @sin)]
  end

  private

  # Whether a point is in the space the box encloses, clear of every panel.
  # Most samples are, and need no closer look.
  def hollow?(x, y, z)
    x.between?(0, width) && y.between?(0, profile.depth) && z.between?(0, profile.height) && on_slope(x, y, z).last.negative?
  end

  # The box and a thickness all round it, which is as far as a tab stands out.
  def ranges(step)
    reach = profile.thickness
    [[-reach, width + reach], [-reach, profile.depth + reach], [-reach, profile.height + reach]]
      .zip(OFFSETS).map { |(from, to), offset| (from / step).floor.upto((to / step).ceil).map { |index| (index + offset) * step } }
  end

  # Whether a point is inside a polygon: a ray from it crosses the sides an odd number of times.
  def inside?(polygon, x, y)
    polygon.each_with_index.count do |(xi, yi), index|
      xj, yj = polygon[index - 1]
      ((yi > y) != (yj > y)) && (x < (((xj - xi) * (y - yi)) / (yj - yi)) + xi)
    end.odd?
  end
end
