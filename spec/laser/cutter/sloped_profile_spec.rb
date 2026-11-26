# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Profile do
        let(:depth) { 6.0 }
        let(:height) { 4.0 }
        let(:front_height) { 1.0 }
        let(:slope) { 45 }
        let(:thickness) { 0.25 }

        subject(:profile) do
          described_class.new(depth: depth, height: height, front_height: front_height, slope: slope, thickness: thickness)
        end

        def xy(point) = point.to_a.map { |c| c.round(9) }

        # The outside face of the tilted panel lies one thickness up and back
        # from its inside face.
        def outside(point)
          a = profile.angle
          point.plus(-thickness * Math.sin(a), thickness * Math.cos(a))
        end

        context 'with both strips' do
          its(:top_depth) { is_expected.to be_within(1e-9).of(3.0) }
          its(:slope_length) { is_expected.to be_within(1e-9).of(3 * Math.sqrt(2)) }

          it 'outlines five corners, counter-clockwise from the front of the bottom' do
            expect(profile.vertices.map { |v| xy(v) }).to eq([[0, 0], [6, 0], [6, 4], [3, 4], [0, 1]])
          end

          it 'meets the top strip with no gap and no overlap' do
            strip_front_corner = [depth - profile.top_strip_length, height]
            expect(xy(outside(profile.tilted_span.p2))).to eq(strip_front_corner.map { |c| c.round(9) })
          end

          it 'meets the front strip with no gap and no overlap' do
            strip_top_corner = [0.0, profile.front_strip_length]
            expect(xy(outside(profile.tilted_span.p1))).to eq(strip_top_corner.map { |c| c.round(9) })
          end

          it 'makes the tilted panel as long as the span it covers' do
            expect(profile.tilted_length).to be_within(1e-9).of(profile.tilted_span.length)
          end

          it 'keeps the span on the slope' do
            low, high = [profile.tilted_span.p1, profile.tilted_span.p2]
            expect((high.y - low.y) / (high.x - low.x)).to be_within(1e-9).of(1.0)
          end
        end

        context 'when the slope reaches the back' do
          let(:front_height) { 4.0 - (6.0 * Math.tan(Math::PI / 6)) }
          let(:slope) { 30 }

          it { is_expected.not_to be_top_strip }
          its(:top_strip_length) { is_expected.to eq(0.0) }

          it 'outlines four corners' do
            expect(profile.vertices.size).to eq(4)
          end

          it 'runs the tilted panel to the back corner' do
            expect(xy(profile.tilted_span.p2)).to eq([6.0, 4.0])
          end
        end

        context 'when the slope starts at the bottom' do
          let(:front_height) { 0 }

          it { is_expected.not_to be_front_strip }
          its(:front_strip_length) { is_expected.to eq(0.0) }

          it 'outlines four corners' do
            expect(profile.vertices.map { |v| xy(v) }).to eq([[0, 0], [6, 0], [6, 4], [4, 4]])
          end

          it 'runs the tilted panel from the front corner' do
            expect(xy(profile.tilted_span.p1)).to eq([0.0, 0.0])
          end
        end

        describe 'refusing what it cannot draw' do
          def build(**overrides)
            described_class.new(depth: depth, height: height, front_height: front_height,
                                slope: slope, thickness: thickness, **overrides)
          end

          [0, 90, -5, 120].each do |angle|
            it "refuses a #{angle}° slope" do
              expect { build(slope: angle) }.to raise_error(InvalidOption, /slope must be between/)
            end
          end

          it 'refuses a slope too shallow for the depth' do
            expect { build(slope: 20) }.to raise_error(InvalidOption, /needs a depth/)
          end

          it 'refuses a front as tall as the back' do
            expect { build(front_height: 4) }.to raise_error(InvalidOption, /must be below/)
          end

          it 'refuses a negative front height' do
            expect { build(front_height: -1) }.to raise_error(InvalidOption, /at least zero/)
          end

          it 'refuses a zero thickness' do
            expect { build(thickness: 0) }.to raise_error(InvalidOption, /thickness must be above zero/)
          end
        end
      end
    end
  end
end
