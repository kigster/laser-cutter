# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    RSpec.describe Options do
      subject(:options) { described_class.new(settings) }

      let(:dimensions) { { width: 40, height: 30, depth: 20, thickness: 3 } }
      let(:settings) { dimensions }

      describe 'with the dimensions alone' do
        its(:width) { is_expected.to eql(40.0) }
        its(:thickness) { is_expected.to eql(3.0) }
        its(:units) { is_expected.to eq('in') }
        its(:lid) { is_expected.to eq('full') }
        its(:page_layout) { is_expected.to eq('portrait') }
        its(:metadata) { is_expected.to be(true) }
        its(:inside_box) { is_expected.to be(false) }
        its(:notch) { is_expected.to be_nil }
        its(:kerf) { is_expected.to be_nil }
        its(:format) { is_expected.to be_nil }
        its(:file) { is_expected.to be_nil }
        its(:page_size) { is_expected.to be_nil }

        it { is_expected.not_to respond_to(:width=) }
      end

      describe 'with what a form sends: Strings, some of them blank' do
        let(:settings) do
          { 'width' => '70', 'height' => '20', 'depth' => '50', 'thickness' => '4.3', 'notch' => '', 'kerf' => '0.1',
            'units' => 'mm', 'lid' => 'plain', 'format' => 'SVG', 'page_size' => 'a4', 'page_layout' => '',
            'metadata' => '0', 'inside_box' => 'true', 'margin' => '', 'padding' => '2', 'stroke' => '0.2' }
        end

        its(:width) { is_expected.to eql(70.0) }
        its(:thickness) { is_expected.to eql(4.3) }
        its(:notch) { is_expected.to be_nil }
        its(:kerf) { is_expected.to eql(0.1) }
        its(:units) { is_expected.to eq('mm') }
        its(:lid) { is_expected.to eq('plain') }
        its(:format) { is_expected.to eq('svg') }
        its(:page_size) { is_expected.to eq('A4') }
        its(:page_layout) { is_expected.to eq('portrait') }
        its(:metadata) { is_expected.to be(false) }
        its(:inside_box) { is_expected.to be(true) }
        its(:margin) { is_expected.to be_nil }
        its(:padding) { is_expected.to eql(2.0) }
        its(:stroke) { is_expected.to eql(0.2) }
      end

      describe 'with Symbols' do
        let(:settings) { dimensions.merge(units: :mm, lid: :back, format: :pdf, page_layout: :landscape) }

        its(:units) { is_expected.to eq('mm') }
        its(:lid) { is_expected.to eq('back') }
        its(:format) { is_expected.to eq('pdf') }
        its(:page_layout) { is_expected.to eq('landscape') }
      end

      describe 'with a slope' do
        let(:settings) { dimensions.merge('slope' => '45', 'front_height' => '10') }

        its(:slope) { is_expected.to eql(45.0) }
        its(:front_height) { is_expected.to eql(10.0) }

        it 'carries both into the configuration' do
          expect(options.to_configuration).to include(slope: 45.0, front_height: 10.0)
        end

        it 'takes a front height of zero' do
          expect(described_class.new(dimensions.merge(slope: 60, front_height: 0)).front_height).to eql(0.0)
        end

        it 'takes a lid that lifts off' do
          expect(described_class.new(settings.merge(lid: :plain)).lid).to eq('plain')
        end
      end

      describe 'without a slope' do
        its(:slope) { is_expected.to be_nil }
        its(:front_height) { is_expected.to be_nil }

        it 'reads blank Strings from a form as no slope' do
          expect(described_class.new(dimensions.merge('slope' => '', 'front_height' => '')).slope).to be_nil
        end
      end

      describe 'given an Options' do
        it 'returns it' do
          expect(described_class.new(options)).to be(options)
        end
      end

      describe '#new' do
        subject(:changed) { options.new(lid: :plain) }

        its(:lid) { is_expected.to eq('plain') }
        its(:width) { is_expected.to eql(40.0) }
      end

      describe 'what it refuses' do
        {
          { lid: 'sliding' }                           => 'lid cannot be "sliding", but must be one of: full, back, plain.',
          { units: 'cm' }                              => 'units cannot be "cm", but must be one of: in, mm.',
          { format: 'dxf' }                            => 'format cannot be "dxf", but must be one of: pdf, svg.',
          { page_layout: 'sideways' }                  => 'page_layout cannot be "sideways", but must be one of: portrait, landscape.',
          { page_size: 'A99' }                         => 'page_size cannot be "A99".',
          { width: 'wide' }                            => 'width cannot be "wide".',
          { depth: 0 }                                 => 'depth cannot be 0.',
          { kerf: -0.1 }                               => 'kerf cannot be -0.1.',
          { metadata: 'maybe' }                        => 'metadata cannot be "maybe".',
          { slope: 90, front_height: 10 }              => 'slope cannot be 90.',
          { slope: 0, front_height: 10 }               => 'slope cannot be 0.',
          { front_height: -1, slope: 45 }              => 'front_height cannot be -1.',
          { front_height: 10 }                         => 'front_height is the front of a sloped box, so it needs a slope.',
          { lid: 'back', slope: 45, front_height: 10 } => 'lid cannot be "back" with a slope, but must be one of: full, plain.'
        }.each do |bad, message|
          it "raises InvalidOption when #{bad.keys.first} is #{bad.values.first.inspect}" do
            expect { described_class.new(dimensions.merge(bad)) }.to raise_error(InvalidOption, message)
          end
        end

        it 'raises InvalidOption for a key that is not an option' do
          expect { described_class.new(dimensions.merge(lids: :plain)) }.to raise_error(InvalidOption, /lids/)
        end

        it 'raises MissingOption naming every dimension left out' do
          expect { described_class.new(width: 40, depth: '') }
            .to raise_error(MissingOption, 'height, depth, thickness are required, but missing.')
        end

        it 'raises MissingOption for a slope without a front height' do
          expect { described_class.new(dimensions.merge(slope: 45)) }
            .to raise_error(MissingOption, 'front_height is required with slope, but missing.')
        end

        it 'raises InvalidOption for a slope the depth cannot take' do
          expect { described_class.new(dimensions.merge(slope: 10, front_height: 10)) }.to raise_error(InvalidOption, /needs a depth of/)
        end

        it 'raises MissingOption naming the one dimension left out' do
          expect { described_class.new(dimensions.except(:width)) }.to raise_error(MissingOption, 'width is required, but missing.')
        end
      end

      describe '#to_configuration' do
        subject(:config) { described_class.new(dimensions.merge(units: :mm, lid: :back, inside_box: true, format: :svg)).to_configuration }

        it { is_expected.to be_a(Configuration) }

        its(:width) { is_expected.to eql(40.0) }
        its(:lid) { is_expected.to eq('back') }
        its(:debug) { is_expected.to be(true) }
        its(:notch) { is_expected.to eql(9.0) }
        its(:kerf) { is_expected.to be_within(1e-6).of(0.06096) }
        its(:format) { is_expected.to be_nil }
      end
    end
  end
end
