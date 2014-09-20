require_relative 'spec_helper'

module Laser
  module Cutter
    describe Box do
      context '#initialize' do
        let(:dim) { Geometry::Dimensions.new(50, 60, 70) }
        let(:box1) { Box.new(dim, 6, 10) }
        let(:box2) { Box.new(dim, 6) }

        it 'should initialize with passed in parameters' do
          expect(box1.w).to eq(50.0)
          expect(box1.thick).to eq(6.0)
          expect(box1.notch).to eq(10.0)
        end

        it 'should initialize with default notch' do
          expect(box2.notch).to eq(12)
        end
      end

    end
  end
end
