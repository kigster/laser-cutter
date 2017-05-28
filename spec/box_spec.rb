require 'spec_helper'
require 'laser-cutter/box'

RSpec.describe ::Laser::Cutter::Box do

  context 'config #1' do
    let(:config) { { 'width' => 50, 'height' => 60, 'depth' => 70, 'margin' => 5, 'padding' => 3, 'units' => 'mm' } }
    let(:box1) { ::Laser::Cutter::Box.new(config.merge('thickness' => 6, 'notch' => 10)) }
    let(:box2) { ::Laser::Cutter::Box.new(config.merge('thickness' => 6)) }

    context '#initialize' do
      it 'should initialize with passed in parameters' do
        expect(box1.w).to eq(50.0)
        expect(box1.thickness).to eq(6.0)
        expect(box1.notch_width).to eq(10.0)
      end

      it 'should initialize with default notch' do
        expect(box2.notch_width).to eq(70.0 / 5.0)
      end
    end

    context '#notches' do
      before do
        box1.generate_notches
        box2.generate_notches
      end
      it 'should generate notches' do
        expect(box1.notches).to_not be_nil
        expect(box1.notches.size).to eql(368)
      end

      let(:dims) { [0, 0, 232, 317] }
      it 'should properly calculate enclosure' do
        expect(box1.enclosure.to_a.flatten.map(&:round)).to eql(dims)
        expect(box2.enclosure.to_a.flatten.map(&:round)).to eql(dims)
      end
    end
  end

end
