require_relative 'spec_helper'

module Laser
  module Cutter
    module Geometry
      describe Point do
        let(:point1) { Point.new(1, 2) }

        context 'creation' do
          context 'from string' do
            it 'should instantiate correctly from a string' do
              expect(Point.new "1,2").to eql(point1)
            end
          end

          context 'from a hash' do
            it 'should instantiate correctly from a hash' do
              expect(Point.new(x: 1, y: 2)).to eql(point1)
            end
          end
        end
        context 'move by' do
          it 'should move properly' do
            p = point1.move_by(10, -2)
            expect(p.x).to be_within(0.001).of(11)
            expect(p.y).to be_within(0.001).of(0)
          end
          it 'should move cloned version properly' do
            p2 = point1.clone.move_by(10, -2)
            expect(p2.x).to be_within(0.001).of(11)
            expect(p2.y).to be_within(0.001).of(0)
          end
        end
      end
    end
  end
end
