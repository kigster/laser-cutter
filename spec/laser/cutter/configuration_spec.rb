# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    RSpec.describe Configuration do
      subject(:config) { described_class.new(opts) }

      context 'when a box is 2x3x2/0.125/0.5' do
        let(:opts) { { 'box' => '2x3x2/0.125/0.5' } }

        its(:width) { is_expected.to eql(2.0) }
        its(:height) { is_expected.to eql(3.0) }
        its(:depth) { is_expected.to eql(2.0) }
        its(:thickness) { is_expected.to eql(0.125) }
        its(:page_layout) { is_expected.to eql('portrait') }
        its(:notch) { is_expected.to eql(0.5) }
      end

      describe '#validate' do
        context 'when required options are missing' do
          let(:opts) { { 'height' => '23' } }

          its(:height) { is_expected.to eql(23.0) }

          it 'raises MissingOption' do
            expect { config.validate! }.to raise_error(Laser::Cutter::MissingOption)
          end
        end

        context 'when a required option is zero' do
          let(:opts) { { 'box' => '2.0x0.0x2/0.125/0.5', 'file' => '/tmp/a' } }

          its(:height) { is_expected.to eql(0.0) }

          it 'raises ZeroValueNotAllowed' do
            expect { config.validate! }.to raise_error(Laser::Cutter::ZeroValueNotAllowed)
          end
        end
      end

      describe 'lid' do
        let(:opts) { { 'box' => '2x3x2/0.125/0.5', 'file' => '/tmp/a' } }

        its(:lid) { is_expected.to eql('full') }

        %w[full back plain].each do |lid|
          it "accepts #{lid}" do
            expect { described_class.new(opts.merge('lid' => lid)).validate! }.not_to raise_error
          end
        end

        it 'rejects anything else' do
          expect { described_class.new(opts.merge('lid' => 'sliding')).validate! }
            .to raise_error(Laser::Cutter::InvalidOption, /lid is "sliding"/)
        end
      end

      context 'when notch is omitted' do
        let(:opts) { { 'box' => '2.0x1.0x2/0.125', 'file' => '/tmp/a' } }

        before { config.validate! }

        its(:thickness) { is_expected.to eql(0.125) }
        its(:notch) { is_expected.to eql(0.375) }
      end

      context 'when invalid units are provided' do
        let(:opts) { { 'box' => '2x3x2/0.125/0.5', 'units' => 'xx' } }

        its(:units) { is_expected.to eql(:in) }
      end

      context 'when converting between units' do
        context 'from inches to mm' do
          let(:opts) { { 'box' => '2.0x3x2/0.125/0.5', 'padding' => '4.2', 'units' => 'in' } }

          its(:width) { is_expected.to eql(2.0) }

          context 'after change_units(:in)' do
            subject(:config) { described_class.new(opts).tap { |c| c.change_units(:in) } }

            its(:width) { is_expected.to eql(2.0) }
          end

          context 'after change_units(:mm)' do
            subject(:config) { described_class.new(opts).tap { |c| c.change_units(:mm) } }

            its(:units) { is_expected.to eql(:mm) }
            its(:width) { is_expected.to eql(50.8) }
            its(:padding) { is_expected.to eql(106.68) }
          end
        end

        context 'from mm to inches' do
          let(:opts) { { 'box' => '20.0x30.0x40.0/5/5', 'margin' => '10.0', 'units' => 'mm' } }

          its(:width) { is_expected.to eql(20.0) }

          context 'after change_units(:mm)' do
            subject(:config) { described_class.new(opts).tap { |c| c.change_units(:mm) } }

            its(:width) { is_expected.to eql(20.0) }
          end

          context 'after change_units(:in)' do
            subject(:config) { described_class.new(opts).tap { |c| c.change_units(:in) } }

            its(:width) { is_expected.to be_within(0.00001).of(0.787401575) }
            its(:margin) { is_expected.to be_within(0.00001).of(0.393700787) }
            its(:units) { is_expected.to eql(:in) }
          end
        end
      end
    end
  end
end
