# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Panels do
        include_context 'with a sloped box'

        subject(:panels) { described_class.new(profile: profile, width: width, notcher: notcher, lid: lid) }

        let(:outlines) { panels.to_h }
        let(:span) { profile.tilted_span }

        def tabs(name, from, to)
          from, to = [from, to].map { |corner| corner.is_a?(Array) ? point(*corner) : corner }
          Loops.tabs(outlines[name].lines, from: from, to: to, thickness: thickness)
        end

        # Each joint as the same stretch on its two panels, walked the way each outline runs.
        def joints
          top = profile.top_depth
          tilted = profile.tilted_length
          {
            'side to bottom'  => [['left', [0, 0], [depth, 0]], ['bottom', [0, depth], [0, 0]]],
            'side to back'    => [['left', [depth, 0], [depth, height]], ['back', [0, height], [0, 0]]],
            'side to top'     => [['left', [depth, height], [depth - top, height]], ['top', [0, top], [0, 0]]],
            'side to tilted'  => [['left', span.p2, span.p1], ['tilted', [0, tilted], [0, 0]]],
            'side to front'   => [['left', [0, front_height], [0, 0]], ['front', [width, 0], [width, front_height]]],
            'bottom to back'  => [['bottom', [width, depth], [0, depth]], ['back', [0, 0], [width, 0]]],
            'back to top'     => [['back', [width, height], [0, height]], ['top', [0, 0], [width, 0]]],
            'bottom to front' => [['bottom', [0, 0], [width, 0]], ['front', [0, 0], [width, 0]]]
          }
        end

        def interlocking
          joints.select { |_name, sides| sides.all? { |panel, _from, _to| outlines.key?(panel) } }.transform_values do |ours, theirs|
            from, to = ours.drop(1).map { |corner| corner.is_a?(Array) ? point(*corner) : corner }
            Loops.interlock?(tabs(*ours), tabs(*theirs), Math.hypot(to.x - from.x, to.y - from.y))
          end
        end

        shared_examples 'a box that fits together' do |joint_count|
          it "interlocks at each of its #{joint_count} joints" do
            expect(interlocking).to eq(interlocking.transform_values { true }).and have_attributes(size: joint_count)
          end

          it 'draws no outline that crosses itself' do
            expect(outlines.values.map { |outline| Loops.simple?(outline.lines) }).to all(be(true))
          end

          it 'gives every panel a size' do
            expect(panels.sizes.keys).to eq(outlines.keys)
          end
        end

        context 'with both strips' do
          it_behaves_like 'a box that fits together', 8

          it 'has seven panels' do
            expect(outlines.keys).to eq(Panels::NAMES)
          end

          it 'draws both side walls alike' do
            expect(corners_of(outlines['left'])).to eq(corners_of(outlines['right']))
          end

          it 'sizes the strips and the tilted panel as the profile says' do
            expect(panels.sizes.values_at('top', 'tilted', 'front'))
              .to eq([[4.0, profile.top_strip_length], [4.0, profile.tilted_length], [4.0, profile.front_strip_length]])
          end

          it 'runs each strip a thickness wide over the end of the tilted panel' do
            far = [profile.top_strip_length, profile.front_strip_length]
            ends = %w[top front].zip(far).map { |name, y| corners_of(outlines[name]).select { |_x, cy| (cy - y).abs < 1e-6 }.map(&:first).minmax }
            expect(ends).to eq([[-0.25, 4.25], [-0.25, 4.25]])
          end

          it 'gives each corner cube to the back or the front strip' do
            expect(%w[back front].map { |name| corners_of(outlines[name]).include?([-0.25, -0.25]) }).to eq([true, true])
          end

          it 'keeps the bottom and the top strip out of the corners' do
            expect(%w[bottom top].flat_map { |name| corners_of(outlines[name]).select { |x, y| x < 0 && y < 0 } }).to be_empty
          end
        end

        context 'when the back and the front strip cannot carry a corner' do
          let(:notch) { 0.7 }

          it_behaves_like 'a box that fits together', 8

          it 'gives each corner cube to the bottom or the top strip' do
            carried = { 'bottom' => [[-0.25, -0.25], [-0.25, 5.25]], 'top' => [[-0.25, -0.25]] }
            expect(carried.map { |name, corners| corners_of(outlines[name]).intersection(corners).size }).to eq([2, 1])
          end

          it 'keeps the back and the front strip out of the corners' do
            expect(%w[back front].flat_map { |name| corners_of(outlines[name]).select { |x, y| x < 0 && (y < 0 || y > height) } }).to be_empty
          end
        end

        context 'with a tilted panel that lifts off' do
          let(:lid) { :plain }

          it 'interlocks at the other seven joints' do
            expect(interlocking.except('side to tilted').values).to all(be(true)).and have_attributes(size: 7)
          end

          it 'leaves the slope of the side walls plain' do
            expect(tabs('left', span.p2, span.p1)).to be_empty
          end

          it 'draws the tilted panel as a rectangle' do
            expect(outlines['tilted'].lines.size).to eq(4)
          end

          it 'lays the tilted panel over both side walls' do
            expect(corners_of(outlines['tilted']).map(&:first).minmax).to eq([-0.25, 4.25])
          end
        end

        context 'without a top strip' do
          let(:slope) { Math.atan(2.0 / 5.0) * 180 / Math::PI }

          it_behaves_like 'a box that fits together', 6

          it 'has no top strip' do
            expect(outlines.keys).to eq(Panels::NAMES - ['top'])
          end

          it 'ends the back plain at its top, between the side walls' do
            expect(corners_of(outlines['back']).select { |_x, y| (y - height).abs < 1e-6 }.map(&:first).minmax).to eq([0.0, 4.0])
          end
        end

        context 'without a front strip' do
          let(:front_height) { 0 }
          let(:slope) { 50 }

          it_behaves_like 'a box that fits together', 6

          it 'has no front strip' do
            expect(outlines.keys).to eq(Panels::NAMES - ['front'])
          end

          it 'ends the bottom plain at its front, between the side walls' do
            expect(corners_of(outlines['bottom']).select { |_x, y| y.abs < 1e-6 }.map(&:first).minmax).to eq([0.0, 4.0])
          end
        end

        context 'with neither strip' do
          let(:front_height) { 0 }
          let(:slope) { Math.atan(3.0 / 5.0) * 180 / Math::PI }

          it_behaves_like 'a box that fits together', 4

          it 'has five panels' do
            expect(outlines.keys).to eq(%w[left right bottom back tilted])
          end
        end

        [[30, 0.5], [60, 1.5], [75, 2.0]].each do |angle, front|
          context "at #{angle} degrees from a front #{front} high" do
            let(:slope) { angle }
            let(:front_height) { front }

            it_behaves_like 'a box that fits together', 8
          end
        end
      end
    end
  end
end
