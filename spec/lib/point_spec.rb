require 'spec_helper'

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

            it 'should create point from class method' do
              expect(Point[1,2]).to eql(p1)
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
            p = p1.plus(10, -2)
            expect(p.x).to be_within(0.001).of(11)
            expect(p.y).to be_within(0.001).of(0)
          end
          it 'should move cloned version properly' do
            p2 = p1.clone.plus(10, -2)
            expect(p2.x).to be_within(0.001).of(11)
            expect(p2.y).to be_within(0.001).of(0)
          end
        end

        context 'ordering and equality' do
          let(:p1) { Point[0,0]}
          let(:p2) { Point[10,0]}
          let(:p3) { Point[0,10]}
          let(:p4) { Point[10,10]}
          let(:p5) { Point[-1,-1]}
          it 'should propertly sort' do
            expect([p3,p2,p1,p4,p5].sort).to eql([p5,p1,p3,p2,p4])
          end
          it 'should detect equality' do
            expect(p1).to_not eql(p2)
            expect(p2).to eql(Point[10,0])
          end
        end

      end
    end
  end
end
