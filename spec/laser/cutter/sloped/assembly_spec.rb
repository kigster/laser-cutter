# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      # The panels, stood up in space the way they are glued. Two panels that
      # both claim a point of material cannot be put together, and that is
      # what catches a corner cube given to two panels, or a strip that runs
      # into the tilted panel.
      RSpec.describe 'the sloped box, put together' do
        include_context 'with a sloped box'

        let(:panels) { Panels.new(profile: profile, width: width, notcher: notcher, lid: lid) }
        let(:solid) { Solid.new(profile: profile, width: width, outlines: panels.to_h) }

        shared_examples 'panels that fit' do
          it 'has no material that two panels both claim' do
            expect(solid.collisions).to be_empty
          end
        end

        it_behaves_like 'panels that fit'

        it 'finds the panel a point of material belongs to' do
          owners = [[-0.1, 2.5, 1.0], [2.0, 2.5, -0.1], [2.0, 5.1, 1.5], [2.0, 4.0, 3.1], [2.0, 1.0, 2.1], [2.0, -0.1, 0.5]]
          expect(owners.map { |point| solid.owners_of(*point) }).to eq([['left'], ['bottom'], ['back'], ['top'], ['tilted'], ['front']])
        end

        # The back is taller than the front strip, so in its place it runs into the side walls.
        it 'would catch a panel standing where another already is' do
          doubled = Solid.new(profile: profile, width: width, outlines: panels.to_h.merge('front' => panels.to_h['back']))
          expect(doubled.collisions.keys).to include('front+left', 'front+right')
        end

        context 'when the bottom and the top strip carry the corners' do
          let(:notch) { 0.7 }

          it_behaves_like 'panels that fit'
        end

        context 'with a tilted panel that lifts off' do
          let(:lid) { :plain }

          it_behaves_like 'panels that fit'
        end

        context 'at 60 degrees from a front half as high as the back' do
          let(:slope) { 60 }
          let(:front_height) { 1.5 }

          it_behaves_like 'panels that fit'
        end

        context 'without a front strip' do
          let(:front_height) { 0 }
          let(:slope) { 50 }

          it_behaves_like 'panels that fit'
        end

        context 'without a top strip' do
          let(:slope) { Math.atan(2.0 / 5.0) * 180 / Math::PI }

          it_behaves_like 'panels that fit'
        end

        context 'with neither strip' do
          let(:front_height) { 0 }
          let(:slope) { Math.atan(3.0 / 5.0) * 180 / Math::PI }

          it_behaves_like 'panels that fit'
        end
      end
    end
  end
end
