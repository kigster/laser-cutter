# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe RingPanel do
        include_context 'with a sloped box'

        let(:length) { 3.0 }
        let(:settings) { { joint: length } }

        subject(:outline) { described_class.new(notcher: notcher, width: width, length: length, **settings).loop }

        def tabs(from, to)
          Loops.tabs(outline.lines, from: point(*from), to: point(*to), thickness: thickness).map { |run| run.map { |d| d.round(6) } }
        end

        context 'lying on the side walls, with both edges plain' do
          let(:settings) { { joint: 0.0 } }

          it 'is a rectangle a thickness wider at each end' do
            expect(corners_of(outline)).to contain_exactly([-0.25, 0], [4.25, 0], [4.25, 3], [-0.25, 3])
          end
        end

        context 'notched into the side walls end to end, with both edges plain' do
          it 'keeps its plain edges between the walls' do
            expect(corners_of(outline).select { |_x, y| [0.0, 3.0].include?(y) }.map(&:first).minmax).to eq([0.0, 4.0])
          end

          it 'has a tab in the middle of each end' do
            expect(tabs([4, 0], [4, 3]).any? { |from, to| from < 1.5 && to > 1.5 }).to be(true)
          end

          it 'notches both ends alike' do
            expect(tabs([4, 0], [4, 3])).to eq(tabs([0, 3], [0, 0]))
          end

          # Three tabs of 3/7 at each end, a thickness deep.
          it 'covers what its tabs add to the rectangle' do
            expect(outline.area).to be_within(1e-9).of((4 * 3) + (2 * 3 * (3.0 / 7) * thickness))
          end
        end

        context 'with a notched near edge, and ends notched part of the way' do
          let(:settings) { { joint: 2.0, near: false } }

          # 2 / 0.6 comes to five notches of 0.4, the last of them a tab.
          it 'notches each end as far as the joint' do
            expect(tabs([4, 0], [4, 3]).first(2)).to eq([[0.0, 0.4], [0.8, 1.2]])
          end

          it 'covers the wall from there on, a thickness out, in one run with its last tab' do
            expect(tabs([4, 0], [4, 3]).last).to eq([1.6, 3.0])
          end

          it 'ends a thickness wide at its far edge' do
            expect(corners_of(outline)).to include([4.25, 3.0], [-0.25, 3.0])
          end

          it 'has a hole in the middle of the near edge' do
            expect(tabs([0, 0], [4, 0]).none? { |from, to| from < 2 && to > 2 }).to be(true)
          end

          it 'does not cross itself' do
            expect(Loops.simple?(outline.lines)).to be(true)
          end
        end

        context 'carrying the corners of its near edge' do
          let(:settings) { { joint: length, near: true, corners: [:near] } }

          it 'reaches round both outer corners' do
            expect(corners_of(outline)).to include([-0.25, -0.25], [4.25, -0.25])
          end

          it 'leaves the far corners alone' do
            expect(corners_of(outline)).not_to include([-0.25, 3.25], [4.25, 3.25])
          end

          it 'does not cross itself' do
            expect(Loops.simple?(outline.lines)).to be(true)
          end
        end

        context 'carrying the corners of its far edge' do
          let(:settings) { { joint: length, near: true, far: true, corners: [:far] } }

          it 'reaches round both outer corners' do
            expect(corners_of(outline)).to include([-0.25, 3.25], [4.25, 3.25])
          end

          it 'leaves the near corners alone' do
            expect(corners_of(outline)).not_to include([-0.25, -0.25], [4.25, -0.25])
          end
        end
      end
    end
  end
end
