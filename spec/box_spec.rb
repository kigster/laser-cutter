require_relative 'spec_helper'

module Laser
  module Cutter
    describe Box do
      context '#initialize' do
        let(:config) { {'width' => 50, 'height' => 60, 'depth' => 70, 'margin' => 5, 'padding' => 3 } }
        let(:box1) { Box.new(config.merge('thickness' => 6, 'notch' => 10)) }
        let(:box2) { Box.new(config.merge('thickness' => 6, )) }

        it 'should initialize with passed in parameters' do
          expect(box1.w).to eq(50.0)
          expect(box1.thickness).to eq(6.0)
          expect(box1.notch_width).to eq(10.0)
        end

        it 'should initialize with default notch' do
          expect(box2.notch_width).to eq(70.0 / 5.0)
        end
      end

    end
  end
end
