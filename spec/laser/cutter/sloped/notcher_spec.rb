# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Notcher do
        subject(:notcher) { described_class.new(notch_width: 0.6, thickness: 0.25) }

        def point(x, y) = Geometry::Point[x, y]
        def rounded(points) = points.map { |corner| corner.to_a.map { |c| c.round(6) + 0.0 } }

        it { is_expected.to be_frozen }
        its(:thickness) { is_expected.to eq(0.25) }

        describe '#path' do
          it 'runs from the one corner to the other' do
            path = notcher.path(point(0, 0), point(3, 0), center_out: false)
            expect(rounded([path.first, path.last])).to eq([[0, 0], [3, 0]])
          end

          it 'notches to the right of the way it runs' do
            path = notcher.path(point(0, 0), point(3, 0), center_out: true)
            expect(rounded(path).map(&:last).uniq.sort).to eq([-0.25, 0.0])
          end

          it 'notches an upward run towards larger x' do
            path = notcher.path(point(0, 0), point(0, 3), center_out: true)
            expect(rounded(path).map(&:first).uniq.sort).to eq([0.0, 0.25])
          end

          it 'takes no kerf: the first notch is as long as the rest' do
            path = rounded(notcher.path(point(0, 0), point(3, 0), center_out: false))
            expect(path.each_cons(2).map { |a, b| (b[0] - a[0]).abs.round(5) }.reject(&:zero?).uniq).to eq([0.42857])
          end
        end

        describe '#tab_first?' do
          # 3 / 0.6 comes to 7 notches, so the middle one is the fourth: the first is its opposite.
          it 'begins with a hole when seven notches have a tab in the middle' do
            expect(notcher.tab_first?(3, center_out: true)).to be(false)
          end

          it 'begins with a tab when seven notches have a hole in the middle' do
            expect(notcher.tab_first?(3, center_out: false)).to be(true)
          end

          # 4 / 0.6 comes to 9 notches, so the first matches the middle one.
          it 'begins with a tab when nine notches have a tab in the middle' do
            expect(notcher.tab_first?(4, center_out: true)).to be(true)
          end
        end
      end
    end
  end
end
