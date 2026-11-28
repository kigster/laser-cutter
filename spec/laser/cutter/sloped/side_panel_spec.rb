# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe SidePanel do
        include_context 'with a sloped box'

        subject(:outline) { described_class.new(profile: profile, notcher: notcher, lid: lid).loop }

        let(:span) { profile.tilted_span }

        def tabs(from, to) = Loops.tabs(outline.lines, from: from, to: to, thickness: thickness)
        def rounded(corner) = corner.to_a.map { |c| c.round(6) + 0.0 }

        it 'does not cross itself' do
          expect(Loops.simple?(outline.lines)).to be(true)
        end

        it 'has a hole in the middle of every square edge' do
          edges = [[[0, 0], [5, 0]], [[5, 0], [5, 3]], [[5, 3], [2, 3]], [[0, 1], [0, 0]]]
          middles = edges.map do |from, to|
            half = Math.hypot(to[0] - from[0], to[1] - from[1]) / 2
            tabs(point(*from), point(*to)).any? { |start, finish| start < half && finish > half }
          end
          expect(middles).to all(be(false))
        end

        it 'is notched along the slope, over the span of the tilted panel' do
          expect(tabs(span.p2, span.p1)).not_to be_empty
        end

        # 0.25 / sin 45 is 0.353553: how far the strips run past the corners.
        it 'closes the wedge under the top strip with a triangle up to the strip' do
          expect(corners_of(outline)).to include([2.0, 3.0], [1.646447, 3.0], rounded(span.p2))
        end

        it 'closes the wedge behind the front strip with a triangle up to its top' do
          expect(corners_of(outline)).to include([0.0, 1.0], [0.0, 1.353553], rounded(span.p1))
        end

        it 'stays within a thickness of the profile' do
          xs, ys = corners_of(outline).transpose
          expect([xs.minmax, ys.minmax]).to eq([[-0.25, 5.25], [-0.25, 3.25]])
        end

        context 'under a tilted panel that lifts off' do
          let(:lid) { :plain }

          it 'runs straight down the slope' do
            expect(tabs(span.p2, span.p1)).to be_empty
          end

          it 'keeps both triangles' do
            expect(corners_of(outline)).to include([1.646447, 3.0], [0.0, 1.353553])
          end
        end

        context 'without a top strip' do
          let(:slope) { Math.atan(2.0 / 5.0) * 180 / Math::PI }

          it 'runs the slope from the top of the back' do
            expect(rounded(span.p2)).to eq([5.0, 3.0])
          end

          it 'does not cross itself' do
            expect(Loops.simple?(outline.lines)).to be(true)
          end
        end

        context 'without a front strip' do
          let(:front_height) { 0 }
          let(:slope) { 50 }

          it 'runs the slope down to the front of the bottom' do
            expect(rounded(span.p1)).to eq([0.0, 0.0])
          end

          it 'does not cross itself' do
            expect(Loops.simple?(outline.lines)).to be(true)
          end
        end

        context 'with neither strip' do
          let(:front_height) { 0 }
          let(:slope) { Math.atan(3.0 / 5.0) * 180 / Math::PI }

          it 'is a wedge notched on all three sides' do
            sides = [[point(0, 0), point(5, 0)], [point(5, 0), point(5, 3)], [span.p2, span.p1]]
            expect(sides.map { |from, to| tabs(from, to) }).to all(satisfy { |found| !found.empty? })
          end
        end
      end
    end
  end
end
