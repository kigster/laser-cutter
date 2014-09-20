require_relative 'spec_helper'

describe Laser::Cutter::Box do
  context '#initialize' do
    let(:dim) { Laser::Cutter::Dimension.new(50, 60, 70)}
    let(:box1) { Laser::Cutter::Box.new(dim, 6, 10) }
    let(:box2) { Laser::Cutter::Box.new(dim, 6) }

    it 'should initialize with passed in parameters' do
      expect(box1.width).to eq(50.0)
      expect(box1.thick).to eq(6.0)
      expect(box1.notch).to eq(10.0)
    end

    it 'should initialize with default notch' do
      expect(box2.notch).to eq(12)
    end
  end

  context '#render' do
    let (:box) { Laser::Cutter::Box.new(Laser::Cutter::Dimension.new(80, 30, 10), 6) }
    it 'should layout correctly' do

    end

    it 'should save a PDF file' do
      box.render
      `open ./output.pdf`
    end

  end

end
