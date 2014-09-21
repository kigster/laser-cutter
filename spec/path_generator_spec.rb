require_relative 'spec_helper'

module Laser
  module Cutter
    module Geometry
      describe PathGenerator do
        let(:notch) { 2 }
        let(:thickness) { 1 }
        let(:center_out) { true }
        let(:fill_edge) { true }
        let(:outside) { Line.new(from: [0, 0], to: [10, 0]) }
        let(:inside) { Line.new(from: [1, 1], to: [9, 1]) }
        let(:edge) { Edge.new(outside, inside, notch) }
        let(:generator) { PathGenerator.new(notch_width: notch,
                                            thickness: thickness,
                                            center_out: center_out,
                                            fill_edge: fill_edge) }
        context 'edge' do
          it 'should properly calculate notch size' do
            expect(edge.notch_width).to be_within(0.001).of(8.0/5.0)
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
          let(:iterator) {AlternatingIterator.new([:a, :b, :c])}
          it 'returns things in alternating order' do
            expect(iterator.next).to eq(:a)
            expect(iterator.next).to eq(:b)
            expect(iterator.next).to eq(:c)
            expect(iterator.next).to eq(:a)
          end
        end

        context 'shift definition' do

          it 'correctly defines shifts' do
            shifts = generator.send(:define_shifts, edge)
            expect(edge.outside.length).to eql(10.0)
            expect(edge.inside.length).to eql(8.0)
            expect(edge.notch_width).to be_within(0.001).of(1.6)
            expect(edge.notch_count).to eql(5)
            expect(shifts.size).to eql(11)
          end
        end


        context 'path generation' do
          let(:outside) { Line.new(
              from: inside.p1.move_by(-thickness, -thickness),
              to: inside.p2.move_by(thickness, -thickness)) }

          context 'center out' do
            it 'generates correct path' do
              inside.freeze
              expect(inside.p1).to_not eql(inside.p2)
              path = generator.path(edge)
              expect(path).to be_a_kind_of(NotchedPath)
              expect(path.size).to eq(12)
              expect(path[0]).to eql(inside.p1)
              expect(path[11]).to eql(inside.p2)

              # Sanity Check
              expect(Point.new(1,1)).to eql(inside.p1)
              expect(Point.new(9,1)).to eql(inside.p2)

            end
          end
        end

      end
    end
  end
end
