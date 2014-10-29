require_relative 'spec_helper'

module Laser
  module Cutter
    module Notching
      describe PathGenerator do
        let(:notch) { 2 }
        let(:thickness) { 1 }
        let(:center_out) { true }
        let(:corners) { true }

        let(:options) { {notch_width: notch,
                         thickness: thickness,
                         center_out: center_out,
                         corners: corners} }

        let(:outside) { Geometry::Line.new(from: [0, 0], to: [10, 0]) }
        let(:inside)  { Geometry::Line.new(from: [1, 1], to: [9,  1]) }
        let(:edge) { Edge.new(outside, inside, options) }
        let(:generator) { PathGenerator.new(edge) }

        context 'edge' do
          it 'should properly calculate notch size' do
            expect(edge.notch_width).to be_within(0.001).of(1.6)
          end
          context 'edge cases with the edge :)' do
            let(:notch) { 15 } # too big
            it 'should properly handle edge cases' do
              # 3 is the minimum number of notches we support per side
              expect(edge.notch_width).to be_within(0.001).of(8.0/3.0)
            end
          end
        end

        context 'alternating iterator' do
          let(:a) { "hello" }
          let(:b) { "again" }
          let(:iterator) { InfiniteIterator.new([a,b]) }
          it 'returns things in alternating order' do
            expect(iterator.next).to eq(a)
            expect(iterator.next).to eq(b)
            expect(iterator.next).to eq(a)
          end
        end

        context 'shift definition' do

          it 'correctly defines shifts' do
            shifts = generator.send(:define_shifts)
            expect(edge.outside.length).to eql(10.0)
            expect(edge.inside.length).to eql(8.0)
            expect(edge.notch_width).to be_within(0.001).of(1.6)
            expect(edge.notch_count).to eql(5)
            expect(shifts.size).to eql(11)
          end
        end


        context 'path generation' do
          # let(:outside) { Line.new(
          #     from: inside.p1.plus(-thickness, -thickness),
          #     to: inside.p2.plus(thickness, -thickness)) }

          context 'center out' do
            it 'generates correct path vertices' do
              expect(inside.p1).to_not eql(inside.p2)
              lines = generator.generate
              expect(lines.size).to be > 5

              expect(Geometry::Line.new(lines.first.p1, inside.p1).length).to be_within(0.001).of(0)
              expect(Geometry::Line.new(lines.last.p2, inside.p2).length).to be_within(0.001).of(0)

              # Sanity Check
              expect(Geometry::Point.new(1, 1)).to eql(inside.p1)
              expect(Geometry::Point.new(9, 1)).to eql(inside.p2)
            end

            it 'generates correct lines' do
              lines = generator.generate
              expect(lines.size).to eq(19)
            end
          end
        end

      end
    end
  end
end
