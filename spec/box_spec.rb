require_relative 'spec_helper'

describe Laser::Cutter::Box do
  context '#initialize' do
    let(:dim) { Laser::Cutter::Geometry::Dimensions.new(50, 60, 70)}
    let(:box1) { Laser::Cutter::Box.new(dim, 6, 10) }
    let(:box2) { Laser::Cutter::Box.new(dim, 6) }

    it 'should initialize with passed in parameters' do
      expect(box1.w).to eq(50.0)
      expect(box1.thick).to eq(6.0)
      expect(box1.notch).to eq(10.0)
    end

    it 'should initialize with default notch' do
      expect(box2.notch).to eq(12)
    end
  end

  context '#render' do
    let (:box) { Laser::Cutter::Box.new(Laser::Cutter::Dimensions.new(80, 30, 10), 6) }
    it 'should layout correctly' do

    end

    xit 'should save a PDF file' do
      box.render
      `open ./output.pdf`
    end

  end

end
