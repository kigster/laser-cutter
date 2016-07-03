require 'spec_helper'

module Laser
  module Cutter

    describe 'Notching::Edge' do
      context 'left vertical side' do
        let(:notch) { 2 }
        let(:inner)  { Geometry::Line.new(Geometry::Point[1, 1], Geometry::Point[1, 9])}
        let(:outer) { Geometry::Line.new(Geometry::Point[0, 0], Geometry::Point[0, 10]) }
        let(:edge) { Notching::Edge.new(inside, outside,
                                        center_out: true,
                                        fill_corners: true,
                                        notch: notch,
                                        kerf: 0.02,
                                        thickness: 1) }

        it 'should create a node correctly' do
          expect(inside.length).to eql(8.0)
          expect(outside.length).to eql(10.0)
          expect(edge.center_out).to be_truthy
          expect(edge.kerf).to be_within(0.0001).of(0.02)
          expect(edge.thickness).to be_within(0.0001).of(1)
          expect(edge.notch).to be_within(notch / 3.0).of(notch)
        end

        it 'should calculate notch width correctly' do
          expect(inside.length).to eql(8.0)
          expect(outside.length).to eql(10.0)
          expect(edge.center_out).to be_truthy

          expect(edge.kerf).to be_within(0.0001).of(0.02)
          expect(edge.thickness).to be_within(0.0001).of(1)
        end

        it 'should correctly calculate v1 and v2' do
          expect(edge.v1.to_a).to eql([1.0,1.0])
          expect(edge.v2.to_a).to eql([1.0,-1.0])
        end
      end
    end
  end
end
