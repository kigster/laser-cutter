# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Notching
      RSpec.describe AngledEdge do
        let(:thickness) { 0.25 }
        let(:notch) { 0.75 }
        let(:kerf) { 0.0 }
        let(:center_out) { false }
        let(:outward) { :right }
        let(:from) { Geometry::Point[2, 1] }
        # A 5-long run at atan(3/4), about 36.87 degrees.
        let(:to) { Geometry::Point[6, 4] }
        let(:options) { { notch_width: notch, thickness: thickness, kerf: kerf, center_out: center_out } }

        subject(:edge) { described_class.new(from, to, outward: outward, **options) }

        let(:vertices) { edge.lines.flat_map { |line| [line.p1, line.p2] } }
        let(:direction) { [(to.x - from.x) / 5.0, (to.y - from.y) / 5.0] }
        # Unit normal to the left of the run.
        let(:left) { [-direction[1], direction[0]] }

        def along(point) = ((point.x - from.x) * direction[0]) + ((point.y - from.y) * direction[1])
        def across(point) = ((point.x - from.x) * left[0]) + ((point.y - from.y) * left[1])

        it 'joins its lines end to end' do
          expect(edge.lines.each_cons(2).all? { |a, b| a.p2.eql?(b.p1) }).to be(true)
        end

        it 'starts and ends on the inside line' do
          expect([edge.lines.first.p1, edge.lines.last.p2]).to eql([from, to])
        end

        it 'stays between the ends of the run' do
          expect(vertices.map { |v| along(v) }).to all(be_between(-1e-9, 5 + 1e-9))
        end

        context 'with the material to the right of the run' do
          it 'puts every vertex on the inside line or one thickness to its right' do
            expect(vertices.map { |v| across(v).round(9) }.uniq).to contain_exactly(0.0, -thickness)
          end
        end

        context 'with the material to the left of the run' do
          let(:outward) { :left }

          it 'puts every vertex on the inside line or one thickness to its left' do
            expect(vertices.map { |v| across(v).round(9) }.uniq).to contain_exactly(0.0, thickness)
          end
        end

        it 'draws one notch per stretch along the run' do
          runs = edge.lines.count { |line| across(line.p1).round(9) == across(line.p2).round(9) }
          expect(runs).to eq(edge.notch_count)
        end

        it 'matches the turned copy of the same side laid flat' do
          flat = described_class.new(Geometry::Point[0, 0], Geometry::Point[5, 0], outward: outward, **options)
          turned = flat.lines.map { |line| edge.transform.apply(line) }
          expect(turned.zip(edge.lines).all? { |a, b| a.p1.eql?(b.p1) && a.p2.eql?(b.p2) }).to be(true)
        end

        # The tilted panel is a plain rectangle; its end must mate with the
        # sloped wall, so both must agree on the notches.
        describe 'mating with a rectangular panel of the same length' do
          let(:panel) do
            inside = Geometry::Line.new(Geometry::Point[0, 0], Geometry::Point[5, 0])
            outside = Geometry::Line.new(Geometry::Point[-thickness, -thickness], Geometry::Point[5 + thickness, -thickness])
            Edge.new(outside, inside, options.merge(center_out: !center_out))
          end

          it 'has the same notch count and width' do
            expect([edge.notch_count, edge.notch_width]).to eq([panel.notch_count, panel.notch_width])
          end

          it 'starts with a hole where the panel starts with a tab' do
            expect(edge.first_notch_out?).to eq(!panel.first_notch_out?)
          end
        end

        context 'with a kerf' do
          let(:kerf) { 0.01 }

          it 'moves each end out along the run by half the kerf' do
            ends = [edge.lines.first.p1, edge.lines.last.p2].map { |p| along(p).round(9) }
            expect(ends).to eq([-kerf / 2, 5 + (kerf / 2)])
          end
        end

        it 'refuses a run with no length' do
          expect { described_class.new(from, from, outward: outward, **options) }.to raise_error(ArgumentError, /needs a length/)
        end

        it 'refuses an unknown side' do
          expect { described_class.new(from, to, outward: :up, **options) }.to raise_error(ArgumentError, /outward/)
        end
      end
    end
  end
end
