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
end
