# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Box do
        subject(:box) { described_class.new(Configuration.new(settings)) }

        let(:padding) { 0.2 }
        let(:kerf) { 0.0 }
        let(:overrides) { {} }
        let(:settings) do
          { width: 4, height: 3, depth: 5, front_height: 1, slope: 45, thickness: 0.25, notch: 0.6,
            kerf: kerf, padding: padding, units: 'in', file: 'box.pdf' }.merge(overrides)
        end

        # @return [Array(Float, Float, Float, Float)] the least and most x, then y, of a panel
        def bounds(name)
          points = box.outlines.fetch(name).flat_map { |line| [line.p1, line.p2] }
          [*points.map(&:x).minmax, *points.map(&:y).minmax].map { |c| c.round(6) }
        end

        it 'answers what the renderers ask of a box' do
          expect(box).to respond_to(:generate_notches, :notches, :outlines, :enclosure, :metadata=)
        end

        it 'draws seven panels' do
          expect(box.outlines.keys).to eq(%w[left right bottom back top tilted front])
        end

        it 'returns every line of every panel' do
          expect(box.generate_notches.size).to eq(box.outlines.values.sum(&:size)).and eq(box.notches.size)
        end

        it 'closes every outline' do
          expect(box.outlines.values.map { |lines| Outline.closed?(lines) }).to all(be(true))
        end

        # Across: a side wall 5.5, the column 4.5, a side wall 5.5, and two paddings.
        # Up: the bottom 5.5, the back 3.5, the strips and the tilted panel, and four paddings.
        it 'encloses every line, from the corner of the sheet' do
          expect(box.enclosure.to_a.flatten.map { |c| c.round(6) }).to eq([0.0, 0.0, 15.9, 17.335534])
        end

        describe 'the sheet' do
          it 'unfolds the panels around the back, a padding apart' do
            gaps = [bounds('back')[2] - bounds('bottom')[3], bounds('top')[2] - bounds('back')[3],
                    bounds('tilted')[2] - bounds('top')[3], bounds('front')[2] - bounds('tilted')[3],
                    bounds('back')[0] - bounds('left')[1], bounds('right')[0] - bounds('back')[1]]
            expect(gaps.map { |gap| gap.round(6) }).to all(eq(padding))
          end

          it 'lines the column up between the side walls' do
            expect(%w[bottom back top tilted front].map { |name| bounds(name).first(2) }.uniq).to eq([[5.7, 10.2]])
          end

          it 'draws the right wall as the mirror image of the left' do
            axis = (bounds('left')[0] + bounds('right')[1]) / 2
            mirrored = box.outlines['left'].map do |line|
              Geometry::Line.new(Geometry::Point[(2 * axis) - line.p1.x, line.p1.y], Geometry::Point[(2 * axis) - line.p2.x, line.p2.y])
            end
            expect(Loops.rounded(mirrored)).to eq(Loops.rounded(box.outlines['right']))
          end

          it 'turns the front strip so its plain edge faces the tilted panel' do
            lowest = box.outlines['front'].select { |line| [line.p1.y, line.p2.y].all? { |y| (y - bounds('front')[2]).abs < 1e-6 } }
            expect(lowest.map(&:length).map { |length| length.round(6) }).to eq([4.5])
          end
        end

        describe 'room for the metadata' do
          before { box.metadata = Geometry::Point[9, 8] }

          it 'moves the bottom to the right of the block and the left wall above it' do
            expect([bounds('bottom')[0], bounds('left')[2]]).to eq([9.45, 8.45])
          end

          it 'draws afresh once the block is known' do
            before = box.enclosure
            box.metadata = Geometry::Point[20, 20]
            expect(box.enclosure.p2.x).to be > before.p2.x
          end
        end

        describe 'kerf' do
          let(:kerf) { 0.02 }
          let(:plain) { described_class.new(Configuration.new(settings.merge(kerf: 0.0))) }

          it 'grows the sheet by half the kerf on every side' do
            expect(box.enclosure.to_a.flatten.zip(plain.enclosure.to_a.flatten).map { |cut, drawn| (cut - drawn).round(6) })
              .to eq([-0.01, -0.01, 0.01, 0.01])
          end

          it 'keeps every line, each one moved out and none turned' do
            turned = box.outlines['left'].zip(plain.outlines['left']).reject do |cut, drawn|
              ((cut.p2.x - cut.p1.x) * (drawn.p2.y - drawn.p1.y)) - ((cut.p2.y - cut.p1.y) * (drawn.p2.x - drawn.p1.x)) < 1e-9
            end
            expect([box.outlines['left'].size, turned]).to eq([plain.outlines['left'].size, []])
          end

          it 'moves the slope of a side wall out by half the kerf, square to the slope' do
            longest = ->(lines) { lines.reject { |l| (l.p1.x - l.p2.x).abs < 1e-6 || (l.p1.y - l.p2.y).abs < 1e-6 }.max_by(&:length) }
            cut = longest.call(box.outlines['left'])
            drawn = longest.call(plain.outlines['left'])
            offset = ((cut.p1.x - drawn.p1.x) * -Math.sin(Math::PI / 4)) + ((cut.p1.y - drawn.p1.y) * Math.cos(Math::PI / 4))
            expect(offset.abs).to be_within(1e-9).of(0.01)
          end
        end

        describe 'the lid' do
          let(:overrides) { { lid: 'plain' } }

          it 'draws the tilted panel as a rectangle that lies on the side walls' do
            expect([box.outlines['tilted'].size, bounds('tilted').first(2)]).to eq([4, [5.7, 10.2]])
          end
        end

        describe 'the defaults' do
          subject(:box) { described_class.new({ width: 4, height: 3, depth: 5, front_height: 1, slope: 45, thickness: 0.25 }) }

          it 'draws without kerf, padding, notch or lid, from a plain Hash' do
            expect(box.outlines.keys.size).to eq(7)
          end

          it 'takes a notch three times the thickness' do
            expect(box.outlines['tilted'].size).to eq(described_class.new({ width: 4, height: 3, depth: 5, front_height: 1, slope: 45,
                                                                            thickness: 0.25, notch: 0.75 }).outlines['tilted'].size)
          end
        end

        context 'without strips' do
          let(:overrides) { { front_height: 0, slope: Math.atan(3.0 / 5.0) * 180 / Math::PI } }

          it 'draws five panels' do
            expect(box.outlines.keys).to eq(%w[left right bottom back tilted])
          end
        end

        it 'refuses numbers that do not make the shape' do
          expect { described_class.new(Configuration.new(settings.merge(slope: 10))) }.to raise_error(InvalidOption, /needs a depth/)
        end

        it 'exposes the profile it draws' do
          expect(box.profile.top_depth).to be_within(1e-9).of(3.0)
        end
      end
    end
  end
end
