require 'spec_helper'
require 'laser-cutter/helpers/shapes'

module Laser
  module Cutter
    module Strategy
      describe 'Edge' do
        include Laser::Cutter::Helpers::Shapes
        context 'left vertical side' do
          let(:notch) { 2 }
          let(:inner) { _line(_point(1, 1), _point(1, 9)) }
          let(:outer) { _line(_point(0, 0), _point(0, 10)) }
          let(:edge)  { _edge(inner, outer,
                                center_out:   true,
                                fill_corners: true,
                                notch:        notch,
                                kerf:         0.02,
                                thickness:    1) }

          it 'should create a node correctly' do
            expect(inner.length).to eql(8.0)
            expect(outer.length).to eql(10.0)
            expect(edge.center_out).to be_truthy
            expect(edge.kerf).to be_within(0.0001).of(0.02)
            expect(edge.thickness).to be_within(0.0001).of(1)
            expect(edge.notch).to be_within(notch / 3.0).of(notch)
          end

          it 'should calculate notch width correctly' do
            expect(inner.length).to eql(8.0)
            expect(outer.length).to eql(10.0)
            expect(edge.center_out).to be_truthy

            expect(edge.kerf).to be_within(0.0001).of(0.02)
            expect(edge.thickness).to be_within(0.0001).of(1)
          end

          it 'should correctly calculate v1 and v2' do
            expect(edge.v1.to_a).to eql([1.0, 1.0])
            expect(edge.v2.to_a).to eql([1.0, -1.0])
          end
        end
      end
    end
  end
end
