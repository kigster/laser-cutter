# frozen_string_literal: true

RSpec.describe Laser::Cutter::Renderer do
  let(:config) { Laser::Cutter::Configuration.new(box: '4x3x2/0.125', file: 'box') }

  describe '.for' do
    it 'writes a PDF with the layout renderer' do
      expect(described_class.for('PDF', config)).to be_a(described_class::LayoutRenderer)
    end

    it 'writes an SVG with the SVG renderer' do
      expect(described_class.for(:svg, config)).to be_a(described_class::SvgRenderer)
    end

    it 'raises on a format it does not write' do
      expect { described_class.for('dxf', config) }.to raise_error(Laser::Cutter::Error, /unknown format/)
    end
  end
end
