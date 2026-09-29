require 'spec_helper'

module Laser
  module Cutter
    RSpec.describe Aggregator do
      let(:p1) { Geometry::Point[0,  0] }
      let(:p2) { Geometry::Point[2,  0] }
      let(:p3) { Geometry::Point[5,  0] }
      let(:p4) { Geometry::Point[10, 0] }
      let(:p5) { Geometry::Point[0, 12] }

      let(:l1) { Geometry::Line.new(p1, p3) }
      let(:l2) { Geometry::Line.new(p2, p4) }
      let(:l3) { Geometry::Line.new(p2, p5) }
      let(:l4) { Geometry::Line.new(p1, p2) }
      let(:l5) { Geometry::Line.new(p3, p4) }

      let(:lines) { [l1, l2] }

      let(:aggregator) { Aggregator.new(lines) }

      describe '#initialize' do
        it 'initializes with passed in parameters' do
          expect(aggregator.lines.size).to eql(2)
        end
      end

      describe '#dedup' do
        let(:a) { [1, 5, 3, 1, 2, 2, 2, 2] }
        let(:unique_lines) { [l1, l2, l3, l4, l5] }

        it 'removes dups from a simple array' do
          expect(Aggregator.new(a).dedup!.lines).to eql([3, 5])
        end

        context 'short array' do
          let(:lines) { [l1, l2, l1, l1] }
          let(:result) { [l2] }

          it 'removes dupes from lines array' do
            expect(Aggregator.new(lines).dedup!.lines.map(&:to_s)).to eql(result.map(&:to_s))
          end
        end

        context 'long array' do
          let(:lines) { [l4, l1, l2, l3, l4, l3, l4, l5] }
          let(:result) { [l1, l2, l5] }

          it 'removes dupes from lines array' do
            expect(Aggregator.new(lines).dedup!.lines.map(&:to_s)).to eql(result.map(&:to_s))
          end
        end
      end

      describe '#deoverlap' do
        let(:lines) { [l1, l2, l3] }

        let(:deoverlapped) { [l4, l5, l3].sort }

        it 'removes lines that overlap' do
          expect(aggregator.lines.size).to eql(3)
          aggregator.deoverlap!
          expect(aggregator.lines.size).to eql(3)
          expect(aggregator.lines.map(&:to_s)).to eql(deoverlapped.map(&:to_s))
        end
      end
    end
  end
end
p
