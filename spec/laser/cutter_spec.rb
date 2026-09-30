# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

# What a Ruby program, such as the MakeABox.io website, calls instead of the command line.
RSpec.describe Laser::Cutter do
  let(:settings) { { width: 40, height: 30, depth: 20, thickness: 3, units: 'mm' } }
  let(:options) { Laser::Cutter::Options.new(settings) }
  let(:dir) { Dir.mktmpdir }

  after { FileUtils.remove_entry(dir) }

  describe '.render' do
    subject(:document) { described_class.render(options) }

    it { is_expected.to start_with('%PDF') }

    it 'writes no file' do
      expect { Dir.chdir(dir) { document } }.not_to(change { Dir.children(dir) })
    end

    it 'draws an SVG when the options ask for one' do
      expect(described_class.render(options.new(format: :svg))).to include('<svg', 'width="109.46048mm"')
    end

    it 'takes a Hash, the way a form sends it' do
      expect(described_class.render(settings.transform_keys(&:to_s).transform_values(&:to_s))).to start_with('%PDF')
    end

    it 'yields each line it draws' do
      lines = []
      described_class.render(options.new(format: 'svg')) { |line| lines << line }
      expect(lines.size).to eq(280)
    end

    { nil => 280, '' => 280, 'full' => 280, :back => 208, 'back' => 208, :plain => 184, 'plain' => 184 }.each do |lid, lines|
      it "draws #{lines} lines for the lid #{lid.inspect}" do
        svg = described_class.render(settings.merge(lid: lid, format: :svg))
        expect(svg.scan('<line').size).to eq(lines)
      end
    end

    it 'names the lid in the description of an SVG' do
      expect(described_class.render(settings.merge(lid: :plain, format: :svg))).to match(/<desc>.*lid: plain/m)
    end

    it 'leaves the description out of an SVG without metadata' do
      expect(described_class.render(settings.merge(format: :svg, metadata: false))).not_to include('<desc>')
    end

    it 'draws the box without kerf as well in a PDF, when asked' do
      lines = 0
      described_class.render(options.new(inside_box: true)) { lines += 1 }
      expect(lines).to eq(560)
    end

    it 'raises InvalidOption for a lid it does not know' do
      expect { described_class.render(settings.merge(lid: 'sliding')) }.to raise_error(Laser::Cutter::InvalidOption, /lid/)
    end

    it 'raises MissingOption for a dimension left out' do
      expect { described_class.render(settings.except(:depth)) }.to raise_error(Laser::Cutter::MissingOption, /depth is required/)
    end
  end

  describe '.write' do
    let(:path) { File.join(dir, 'box.svg') }

    it 'takes the format from the extension, and returns the path' do
      expect(described_class.write(options.new(file: path, lid: :back))).to eq(path)
      expect(File.read(path).scan('<line').size).to eq(208)
    end

    it 'writes the format it is given, whatever the extension' do
      described_class.write(settings.merge(file: path, format: :pdf))
      expect(File.binread(path)).to start_with('%PDF')
    end

    it 'writes a PDF when the extension says nothing' do
      described_class.write(settings.merge(file: File.join(dir, 'box')))
      expect(File.binread(File.join(dir, 'box'))).to start_with('%PDF')
    end

    it 'raises MissingOption without a file' do
      expect { described_class.write(options) }.to raise_error(Laser::Cutter::MissingOption, /file is required/)
    end
  end

  # app/helpers/home_helper.rb and app/controllers/home_controller.rb, written against 1.0.3.
  describe 'the calls MakeABox.io makes today' do
    let(:form) { { 'width' => '40', 'height' => '30', 'depth' => '20', 'thickness' => '3', 'units' => 'mm', 'lid' => '' } }
    let(:config) { Laser::Cutter::Configuration.new(form.merge(metadata: true)) }
    let(:path) { File.join(dir, 'box.pdf') }

    before { config['file'] = path }

    it 'still draw a box' do
      config.validate!
      Laser::Cutter::Renderer::LayoutRenderer.new(config).render
      expect(File.binread(path)).to start_with('%PDF')
    end

    it 'still list the page sizes' do
      expect(Laser::Cutter::PageManager.new(config.units).page_size_values)
        .to include(['A4', be_within(0.1).of(210), be_within(0.1).of(297)])
    end

    it 'still fail on a missing dimension with an error the website rescues' do
      config.delete(:width)
      expect { config.validate! }.to raise_error(Laser::Cutter::MissingOption)
    end
  end
end
