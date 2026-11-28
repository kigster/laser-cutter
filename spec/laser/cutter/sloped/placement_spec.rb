# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Placement do
        subject(:placement) { described_class.new(Geometry::Point[10, 20], size: [4, 3], **flips) }

        let(:flips) { {} }

        def placed(x, y) = placement.apply(Geometry::Point[x, y]).to_a

        it { is_expected.to be_frozen }

        it 'moves the origin of the panel to its place' do
          expect(placed(0, 0)).to eq([10, 20])
        end

        it 'keeps the panel the way it was drawn' do
          expect(placed(1, 2)).to eq([11, 22])
        end

        it 'keeps its own copy of the origin' do
          origin = Geometry::Point[1, 1]
          placement = described_class.new(origin, size: [4, 3])
          origin.x = 9
          expect(placement.origin.to_a).to eq([1, 1])
        end

        context 'flipped in x' do
          let(:flips) { { flip_x: true } }

          it 'draws the mirror image within the width' do
            expect([placed(0, 0), placed(4, 0), placed(1, 2)]).to eq([[14, 20], [10, 20], [13, 22]])
          end
        end

        context 'flipped in both' do
          let(:flips) { { flip_x: true, flip_y: true } }

          it 'turns the panel half way round within its size' do
            expect([placed(0, 0), placed(4, 3), placed(1, 2)]).to eq([[14, 23], [10, 20], [13, 21]])
          end
        end
      end
    end
  end
end
