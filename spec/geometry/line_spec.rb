require 'spec_helper'

module Laser
  module Cutter
    module Geometry
      describe Line do
        let(:p1) { Point.new(1, 1) }
        let(:p2) { Point.new(7, 11) }
        let(:center) { Point.new((7 + 1) / 2, (11 + 1) / 2) }
        let(:line) { Line.new(p1, p2) }

        context '#center' do
          it 'should calculate' do
            expect(line.center).to eql(center)
          end
        end

        context '#initialize' do
          let(:line2) { Line.new(from: [1, 1], to: [7, 11]) }
          let(:line3) { Line.new(from: Point.new(1, 1), to: Point.new(7, 11)) }
          it 'should create' do
            expect(line2.p1).to eql(Point.new(1, 1))
            expect(line2.p2).to eql(Point.new(7, 11))
          end
          it 'should properly equal identical line' do
            expect(line).to eql(line2)
            expect(line).to eql(line3)
          end

        end

        context '#length' do
          let(:line1) { Line.new(Point.new(0, 0), Point.new(0, 10)) }
          let(:line2) { Line.new(Point.new(0, 0), Point.new(-10, 0)) }
          let(:line3) { Line.new(Point.new(0, 0), Point.new(3, 4)) }
          it 'should calculate' do
            expect(line1.length).to be_within(0.001).of(10)
            expect(line2.length).to be_within(0.001).of(10)
            expect(line3.length).to be_within(0.001).of(5)
          end
        end

        context 'ordering and equality' do
          let(:l1) { Line.new(Point[0, 0], Point[10, 10]) }
          let(:l2) { Line.new(Point[0, 1], Point[10, 10]) }
          let(:l3) { Line.new(Point[0, 0], Point[11, 10]) }
          let(:l4) { Line.new(Point[20, 20], Point[1, 1]) }
          let(:l5) { Line.new(Point[11, 10], Point[0, 0]) }
          it 'should detect equality' do
            expect(l1).to eql(Line.new(l1.p1, l1.p2))
            expect(l1).to_not eql(Line.new(l1.p1, Point[2, 4]))
            expect(l5).to eql(l3)
            expect(l5.hash).to eql(l3.hash)
          end

          it 'should properly compare' do
            list = [l4, l3, l1, l2]
            list.sort!
            expect(list).to eql([l1, l3, l2, l4])
          end

          it 'should properly uniq' do
            list = [l4, l1, l4, l2, l3, l3, l2, l1]
            list.sort!.uniq!
            expect(list).to eql([l1, l3, l2, l4])
          end
        end
        context 'overlaps and such' do
          let(:l1) { Line.new(Point[0, 0], Point[10, 0]) }
          let(:l2) { Line.new(Point[7, 0], Point[15, 0]) }
          let(:l3) { Line.new(Point[20, 0], Point[25, 0]) }
          let(:l4) { Line.new(Point[0, 1], Point[0, 3]) }
          let(:l5) { Line.new(Point[0, -1], Point[0, 2]) }


          context '#overlaps?' do
            it 'should detect overlap' do
              expect(l1.overlaps?(l2)).to be_truthy
              expect(l1.overlaps?(l3)).to be_falsey
              expect(l2.overlaps?(l3)).to be_falsey
              expect(l1.overlaps?(l4)).to be_falsey
              expect(l2.overlaps?(l4)).to be_falsey
              expect(l4.overlaps?(l5)).to be_truthy
            end
          end

          context '#xor' do
            let(:xor) { [ Line.new(Point[0, 0], Point[7, 0]),  Line.new(Point[10, 0], Point[15, 0])]}
            it 'should subtract lines' do
              expect(l1.xor(l2)).to eql(xor)
              expect(l1.overlaps?(l3)).to be_falsey
              expect(l2.overlaps?(l3)).to be_falsey
              expect(l1.overlaps?(l4)).to be_falsey
              expect(l2.overlaps?(l4)).to be_falsey
              expect(l4.overlaps?(l5)).to be_truthy
            end
          end
        end
      end
    end
  end
end
