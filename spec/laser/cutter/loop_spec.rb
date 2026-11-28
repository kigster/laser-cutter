# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Geometry
      RSpec.describe Loop do
        def loop_of(*pairs) = described_class.new(pairs.map { |x, y| Point[x, y] })
        def corners(outline) = outline.points.map { |point| point.to_a.map { |c| c.round(9) + 0.0 } }

        subject(:square) { loop_of([0, 0], [4, 0], [4, 4], [0, 4]) }

        its(:area) { is_expected.to eq(16.0) }
        it { is_expected.to be_frozen }

        it 'joins its corners end to end, back to the first' do
          expect(square.lines.map { |line| [line.p1.to_a, line.p2.to_a] })
            .to eq([[[0, 0], [4, 0]], [[4, 0], [4, 4]], [[4, 4], [0, 4]], [[0, 4], [0, 0]]])
        end

        it 'hands out copies of its corners' do
          square.points.first.x = 9
          expect(corners(square).first).to eq([0, 0])
        end

        describe 'what a walk leaves behind' do
          it 'drops a point given twice' do
            expect(corners(loop_of([0, 0], [4, 0], [4, 0], [4, 4], [0, 4], [0, 0]))).to eq(corners(square))
          end

          it 'drops a point in the middle of a straight run' do
            expect(corners(loop_of([0, 0], [1, 0], [3, 0], [4, 0], [4, 4], [0, 4]))).to eq(corners(square))
          end

          it 'drops a spike, out and straight back' do
            expect(corners(loop_of([0, 0], [4, 0], [4, 4], [4, 6], [4, 4], [0, 4]))).to eq(corners(square))
          end

          it 'drops a spike that ends on the first point' do
            expect(corners(loop_of([0, 0], [4, 0], [4, 4], [0, 4], [0, 0], [-2, 0]))).to eq(corners(square))
          end

          it 'drops a spike that turns back only part of the way' do
            expect(corners(loop_of([0, 0], [6, 0], [4, 0], [4, 4], [0, 4]))).to eq(corners(square))
          end

          it 'keeps a corner a point away from the noise of a float' do
            expect(corners(loop_of([0, 0], [4, 0], [4 + 1e-13, 1e-13], [4, 4], [0, 4])).size).to eq(4)
          end

          it 'refuses a walk that encloses nothing' do
            expect { loop_of([0, 0], [1, 0], [2, 0]) }.to raise_error(ArgumentError, /on one line/)
          end

          it 'refuses fewer than three corners' do
            expect { loop_of([0, 0], [1, 0]) }.to raise_error(ArgumentError, /three corners/)
          end
        end

        describe '#grow' do
          it 'moves every side of a square out' do
            expect(corners(square.grow(0.5))).to eq([[-0.5, -0.5], [4.5, -0.5], [4.5, 4.5], [-0.5, 4.5]])
          end

          it 'grows a clockwise outline outwards too' do
            expect(described_class.new(square.points.reverse).grow(0.5).area).to eq(25.0)
          end

          it 'moves an inside corner out with the sides that meet there' do
            ell = loop_of([0, 0], [4, 0], [4, 2], [2, 2], [2, 4], [0, 4])
            expect(corners(ell.grow(0.25))).to eq([[-0.25, -0.25], [4.25, -0.25], [4.25, 2.25], [2.25, 2.25], [2.25, 4.25], [-0.25, 4.25]])
          end

          it 'keeps a corner that is not square sharp, each side the distance out' do
            grown = loop_of([0, 0], [4, 0], [4, 3]).grow(0.1)
            expect(corners(grown).map { |x, y| [x.round(6), y.round(6)] }).to eq([[-0.3, -0.1], [4.1, -0.1], [4.1, 3.2]])
          end

          it 'shrinks by a negative distance' do
            expect(square.grow(-1).area).to eq(4.0)
          end

          it 'returns itself for no distance' do
            expect(square.grow(0)).to be(square)
          end

          # The box with six panels widens its tabs and narrows its holes by
          # the kerf, edge by edge. Growing the outline it cuts without kerf
          # by half the kerf must come to the same lines.
          it 'grows a panel by half the kerf to what Box draws with that kerf' do
            settings = { width: 70, height: 20, depth: 50, thickness: 4.3, notch: 10, units: 'mm', file: 'box.pdf' }
            plain, cut = [0.0, 0.3].map { |kerf| Box.new(Configuration.new(settings.merge(kerf: kerf))).tap(&:generate_notches) }
            grown = plain.outlines.transform_values { |lines| Loops.rounded(Loops.chain(lines).grow(0.15).lines) }
            expect(grown).to eq(cut.outlines.transform_values { |lines| Loops.rounded(lines) })
          end
        end

        describe '#map' do
          it 'moves every corner' do
            expect(corners(square.map { |point| point.plus(1, 2) })).to eq([[1, 2], [5, 2], [5, 6], [1, 6]])
          end
        end
      end
    end
  end
end
