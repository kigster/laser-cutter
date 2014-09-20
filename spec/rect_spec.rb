require_relative 'spec_helper'

module Laser
  module Cutter
    module Geometry
      describe Rect do
        let(:point1) { Point.new(1, 3) }
        let(:rect1) { Rect.new(point1, 10, 20) }

        context 'sides' do
          it 'sets correctly all attributes' do
            expect(rect1.w).to eql(10)
            expect(rect1.h).to eql(20)
            expect(rect1.position).to eql(rect1.vertices[0])
          end
          it 'it generates four side lines' do
            expect(rect1.sides.size).to eql(4)
            expect(rect1.sides.first).to be_kind_of(Line)
            expect(rect1.sides.first.point1).to eql(point1)
            expect(rect1.sides[0].point1.to_s).to eql("1,3")
            expect(rect1.sides[1].point1.to_s).to eql("11,3")
            expect(rect1.sides[2].point1).to eql(point1.move_by(10, 20))
          end
          it 'can be moved' do
            expect(rect1.sides[0].point1.to_s).to eql("1,3")
            rect1.x = 1000
            rect1.y = 100

            rect1.relocate!
            expect(rect1.sides[0].point1.to_s).to eql("1000,100")
            expect(rect1.sides[1].point1.to_s).to eql("1010,100")
            expect(rect1.sides[2].point1.to_s).to eql("1010,120")
            expect(rect1.sides[3].point1.to_s).to eql("1000,120")

            expect(rect1.sides[0].point2.to_s).to eql("1010,100")
            expect(rect1.sides[1].point2.to_s).to eql("1010,120")
            expect(rect1.sides[2].point2.to_s).to eql("1000,120")
            expect(rect1.sides[3].point2.to_s).to eql("1000,100")
          end
        end
      end
    end
  end
end
