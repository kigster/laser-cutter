require_relative 'spec_helper'

module Laser
  module Cutter
    module Geometry
      describe Point do
        let(:p1) { Point.new(1, 2) }
        context 'creation' do
          context 'from string' do
            it 'should instantiate correctly' do
              expect(Point.new "1,2").to eql(p1)
            end
          end

          context 'from a point' do
            it 'should instantiate correctly' do
              expect(Point.new(Point.new("1,2"))).to eql(p1)
            end
          end

          context 'from an array' do
            it 'should properly duplicate underlying coordinates and not bug out' do
              a = [1, 2]
              p2 = Point.new(a)
              expect(p2).to eql(p1)
              a.shift # modify original array
              # should not affect our point
              expect(p2).to eql(p1)
            end
          end

          context 'from a hash' do
            it 'should instantiate correctly' do
              expect(Point.new(x: 1, y: 2)).to eql(p1)
            end
          end
        end

        context 'move by' do
          it 'should move properly' do
            p = p1.move_by(10, -2)
            expect(p.x).to be_within(0.001).of(11)
            expect(p.y).to be_within(0.001).of(0)
          end
          it 'should move cloned version properly' do
            p2 = p1.clone.move_by(10, -2)
            expect(p2.x).to be_within(0.001).of(11)
            expect(p2.y).to be_within(0.001).of(0)
          end
        end
      end
    end
  end
end
