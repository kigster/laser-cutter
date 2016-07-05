require 'spec_helper'

require 'laser-cutter/helpers/page_manager'
module Laser
  module Cutter
    module Helpers
      describe PageManager do
        let(:pm) { Laser::Cutter::Helpers::PageManager.new(units) }

        context 'a single value' do
          context 'to inches' do
            let(:units) { 'in' }
            it 'should be correct' do
              expect(pm.value_from_units(150)).to be_within(0.0001).of(150.0/72.0)
              expect(pm.value_from_units(150, 'mm')).to be_within(0.0001).of(150.0/25.4)
              expect(pm.value_from_units(150, 'in')).to be_within(0.0001).of(150.0)
            end
          end
          context 'to mm' do
            let(:units) { 'mm' }
            it 'should be correct' do
              expect(pm.value_from_units(150)).to be_within(0.0001).of(25.4 * 150.0 / 72.0)
              expect(pm.value_from_units(150, 'in')).to be_within(0.0001).of(150.0 * 25.4)
              expect(pm.value_from_units(150, 'mm')).to be_within(0.0001).of(150.0)
            end
          end
        end

        context '#list_page_sizes' do
          context 'formatting of output' do
            context 'when using inches' do
              let(:units) { "in" }
              it 'should return the list in inches' do
                expect(pm.all_page_sizes).to match %r(.*B10\:\s+1\.2\s+x\s+1\.7)
              end
            end
            context 'when using mm' do
              let(:units) { "mm" }
              it 'should return the list in mm' do
                expect(pm.all_page_sizes).to match %r(.*B10\:\s+31\.0\s+x\s+44\.0)
              end
            end
          end
        end
      end
    end
  end
end
