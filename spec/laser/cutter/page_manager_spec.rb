# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    RSpec.describe PageManager do
      let(:pm) { Laser::Cutter::PageManager.new(units) }

      context 'a single value' do
        context 'to inches' do
          let(:units) { 'in' }

          it 'is correct' do
            expect(pm.value_from_units(150)).to be_within(0.0001).of(150.0 / 72.0)
            expect(pm.value_from_units(150, 'mm')).to be_within(0.0001).of(150.0 / 25.4)
            expect(pm.value_from_units(150, 'in')).to be_within(0.0001).of(150.0)
          end
        end

        context 'when units are a Symbol, as the configuration defaults them' do
          let(:units) { :in }

          it 'reads them as inches' do
            expect(pm.value_from_units(72)).to be_within(0.0001).of(1.0)
          end
        end

        context 'to mm' do
          let(:units) { 'mm' }

          it 'is correct' do
            expect(pm.value_from_units(150)).to be_within(0.0001).of(25.4 * 150.0 / 72.0)
            expect(pm.value_from_units(150, 'in')).to be_within(0.0001).of(150.0 * 25.4)
            expect(pm.value_from_units(150, 'mm')).to be_within(0.0001).of(150.0)
          end
        end
      end

      describe '#list_page_sizes' do
        context 'formatting of output' do
          context 'when using inches' do
            let(:units) { "in" }

            it 'returns the list in inches' do
              expect(pm.all_page_sizes).to match /.*B10:\s+1\.2\s+x\s+1\.7/
            end
          end

          context 'when using mm' do
            let(:units) { "mm" }

            it 'returns the list in mm' do
              expect(pm.all_page_sizes).to match /.*B10:\s+31\.0\s+x\s+44\.0/
            end
          end
        end
      end
    end
  end
end
