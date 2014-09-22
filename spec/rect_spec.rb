require_relative 'spec_helper'

module Laser
  module Cutter
    module Geometry
      describe Rect do
        let(:p1) { Point[ 1.0,  3.0] }
        let(:p2) { Point[11.0, 23.0] }

        let(:rect1) { Rect.new(p1, p2) }

        context 'creating' do
          it 'creates from a class method' do
            expect(Rect[p1, p2]).to eql(rect1)
          end
        end

        context 'sides' do
          it 'sets correctly all attributes' do
            expect(rect1.w).to eql(10.0)
            expect(rect1.h).to eql(20.0)
            expect(rect1.position).to eql(rect1.vertices[0])
            expect(rect1.p2).to eql(rect1.vertices[2])
          end
          it 'it generates four side lines' do
            expect(rect1.sides.size).to eql(4)
            expect(rect1.sides.first).to be_kind_of(Line)
            expect(rect1.sides.first.p1).to eql(p1)
            expect(rect1.sides[0].p1.to_s).to eql("{1.00000,3.00000}")
            expect(rect1.sides[1].p1.to_s).to eql("{11.00000,3.00000}")
            expect(rect1.sides[2].p1).to eql(p1.move_by(10, 20))
          end
          it 'can be moved' do
            expect(rect1.sides[0].p1.to_s).to eql("{1.00000,3.00000}")
            rect1.x = 1000
            rect1.y = 100
            rect1.relocate!

            expect(rect1.sides[0].p1.to_s).to eql("{1000.00000,100.00000}")
            expect(rect1.sides[1].p1.to_s).to eql("{1010.00000,100.00000}")
            expect(rect1.sides[2].p1.to_s).to eql("{1010.00000,120.00000}")
            expect(rect1.sides[3].p1.to_s).to eql("{1000.00000,120.00000}")

            expect(rect1.sides[0].p2.to_s).to eql("{1010.00000,100.00000}")
            expect(rect1.sides[1].p2.to_s).to eql("{1010.00000,120.00000}")
            expect(rect1.sides[2].p2.to_s).to eql("{1000.00000,120.00000}")
            expect(rect1.sides[3].p2.to_s).to eql("{1000.00000,100.00000}")
          end
        end
      end
    end
  end
end
