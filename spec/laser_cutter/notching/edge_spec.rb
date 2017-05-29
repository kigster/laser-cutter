require 'spec_helper'
require 'laser_cutter/helpers/shapes'

module LaserCutter
  module Strategy
    describe 'Edge' do
      include LaserCutter::Helpers::Shapes::InstanceMethods
      context 'left vertical side' do
        let(:notch) { 2 }
        let(:inner) { line(point(1, 1), point(1, 9)) }
        let(:outer) { line(point(0, 0), point(0, 10)) }
        let(:e) { edge(inner, outer,
                       center_out:   true,
                       fill_corners: true,
                       notch:        notch,
                       kerf:         0.02,
                       thickness:    1) }

        it 'should create a node correctly' do
          expect(inner.length).to eql(8.0)
          expect(outer.length).to eql(10.0)
          expect(e.center_out).to be_truthy
          expect(e.kerf).to be_within(0.0001).of(0.02)
          expect(e.thickness).to be_within(0.0001).of(1)
          expect(e.notch).to be_within(notch / 3.0).of(notch)
        end

        it 'should calculate notch width correctly' do
          expect(inner.length).to eql(8.0)
          expect(outer.length).to eql(10.0)
          expect(e.center_out).to be_truthy

          expect(e.kerf).to be_within(0.0001).of(0.02)
          expect(e.thickness).to be_within(0.0001).of(1)
        end

        it 'should correctly calculate v1 and v2' do
          expect(e.v1.to_a).to eql([1.0, 1.0])
          expect(e.v2.to_a).to eql([1.0, -1.0])
        end
      end
    end
  end


end
