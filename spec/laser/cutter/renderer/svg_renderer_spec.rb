# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Laser::Cutter::Renderer::SvgRenderer do
  subject(:renderer) { described_class.new(config) }

  let(:dir) { Dir.mktmpdir }
  let(:file) { File.join(dir, 'box.svg') }
  let(:settings) { { box: '4x3x2/0.125/0.5', file: file } }
  let(:config) { Laser::Cutter::Configuration.new(settings) }
  let(:svg) { File.read(file) }

  after { FileUtils.remove_entry(dir) }

  its(:total) { is_expected.to eq(328) }

  it 'draws every line, yielding each' do
    yielded = 0
    renderer.render { yielded += 1 }
    expect(yielded).to eq(328)
    expect(svg.scan('<line').size).to eq(328)
  end

  it 'sizes the page in the units of the box' do
    renderer.render
    expect(svg).to include('width="9.2012in" height="11.5512in"')
  end

  # Kerf moves the outline out by half its width, into the margin.
  it 'keeps every line on the page' do
    renderer.render
    coordinates = svg.scan(/[xy][12]="([\d.-]+)"/).flatten.map(&:to_f)
    expect(coordinates.min).to be_within(0.002).of(0.125)
    expect(coordinates.max).to be_within(0.002).of(11.5512 - 0.125)
  end

  it 'describes the box' do
    renderer.render
    expect(svg).to match(/<desc>\s*Made with laser-cutter.*thickness: 0\.125/)
  end

  context 'without metadata' do
    let(:settings) { super().merge(metadata: false) }

    it 'leaves the description out' do
      renderer.render
      expect(svg).not_to include('<desc>')
    end
  end

  context 'with a slope' do
    let(:settings) { { box: '4x3x5/0.25/0.6', slope: 45, front_height: 1, file: file } }

    before { renderer.render }

    it 'draws the seven panels of a sloped box' do
      expect(svg.scan('<line').size).to eq(renderer.total).and eq(Laser::Cutter::Sloped::Box.new(config).notches.size)
    end

    it 'draws lines along the slope' do
      skewed = svg.scan(/x1="([\d.-]+)" y1="([\d.-]+)" x2="([\d.-]+)" y2="([\d.-]+)"/).map { |found| found.map(&:to_f) }
                  .reject { |x1, y1, x2, y2| (x1 - x2).abs < 1e-4 || (y1 - y2).abs < 1e-4 }
      expect(skewed.map { |x1, y1, x2, y2| ((y2 - y1) / (x2 - x1)).abs.round(3) }.uniq).to eq([1.0])
    end

    it 'keeps every line on the page' do
      width, height = svg.match(/viewBox="0 0 ([\d.]+) ([\d.]+)"/).captures.map(&:to_f)
      xs, ys = svg.scan(/[xy][12]="([\d.-]+)"/).flatten.map(&:to_f).each_slice(2).to_a.transpose
      expect([xs.min, ys.min, width - xs.max, height - ys.max]).to all(be_within(0.002).of(0.125))
    end

    it 'describes the slope' do
      expect(svg).to match(/<desc>.*depth: 5\.0, front_height: 1, slope: 45, thickness/m)
    end
  end
end
