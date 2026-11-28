# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Layout do
        subject(:layout) { described_class.new(sizes: sizes, thickness: 0.25, padding: 0.5, metadata: metadata) }

        let(:metadata) { Geometry::Point[0, 0] }
        let(:sizes) do
          { 'left' => [5.0, 3.0], 'right' => [5.0, 3.0], 'bottom' => [4.0, 5.0], 'back' => [4.0, 3.0],
            'top' => [4.0, 3.4], 'tilted' => [4.0, 2.3], 'front' => [4.0, 1.4] }
        end
        let(:origins) { layout.placements.transform_values { |placement| placement.origin.to_a } }

        it { is_expected.to be_frozen }

        # The left wall and the bottom reach a thickness past their own size
        # on each side, and the sheet starts at zero.
        it 'puts the back clear of the left wall and of the bottom' do
          expect(origins['back']).to eq([6.25, 6.25])
        end

        it 'puts a side wall either side of the back, a padding from its notches' do
          expect(origins.values_at('left', 'right')).to eq([[0.25, 6.25], [11.25, 6.25]])
        end

        it 'draws the right wall as the mirror image of the left' do
          expect(layout.placements['right'].apply(Geometry::Point[5, 0]).to_a).to eq([11.25, 6.25])
        end

        it 'puts the bottom under the back' do
          expect(origins['bottom']).to eq([6.25, 0.25])
        end

        it 'stacks the top strip, the tilted panel and the front strip above the back' do
          expect(origins.values_at('top', 'tilted', 'front').map { |x, y| [x, y.round(6)] })
            .to eq([[6.25, 10.25], [6.25, 14.15], [6.25, 16.95]])
        end

        it 'turns the front strip half way round, its notched edge on top' do
          expect(layout.placements['front'].apply(Geometry::Point[0, 0]).to_a.map { |c| c.round(6) }).to eq([10.25, 18.35])
        end

        context 'with a metadata block larger than the left wall and the bottom' do
          let(:metadata) { Geometry::Point[8, 9] }

          it 'moves the back clear of the block' do
            expect(origins['back']).to eq([9.0, 10.0])
          end
        end

        context 'without a top strip' do
          let(:sizes) { super().except('top') }

          it 'puts the tilted panel a padding above the plain top of the back' do
            expect(origins['tilted']).to eq([6.25, 9.75])
          end

          it 'places six panels' do
            expect(origins.keys).to eq(%w[left right bottom back tilted front])
          end
        end

        context 'without a front strip' do
          let(:sizes) { super().except('front') }

          it 'places six panels' do
            expect(origins.keys).to eq(%w[left right bottom back top tilted])
          end
        end
      end
    end
  end
end
