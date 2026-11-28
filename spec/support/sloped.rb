# frozen_string_literal: true

# The sloped box most of the specs draw: 4 wide, 5 deep, 3 high at the back
# and 1 at the front, rising at 45 degrees, in quarter-inch material. Its
# slope runs 2 back, so the top strip is 3 deep.
RSpec.shared_context 'with a sloped box' do
  let(:width) { 4.0 }
  let(:depth) { 5.0 }
  let(:height) { 3.0 }
  let(:front_height) { 1.0 }
  let(:slope) { 45 }
  let(:thickness) { 0.25 }
  let(:notch) { 0.6 }
  let(:lid) { :full }

  let(:profile) do
    Laser::Cutter::Sloped::Profile.new(depth: depth, height: height, front_height: front_height, slope: slope,
                                       thickness: thickness)
  end
  let(:notcher) { Laser::Cutter::Sloped::Notcher.new(notch_width: notch, thickness: thickness) }

  def point(x, y) = Laser::Cutter::Geometry::Point[x, y]

  # @return [Array<Array(Float, Float)>] the corners of an outline, rounded
  def corners_of(outline) = outline.points.map { |corner| corner.to_a.map { |c| c.round(6) + 0.0 } }
end
