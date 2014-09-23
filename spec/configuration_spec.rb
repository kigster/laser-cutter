require_relative 'spec_helper'

module Laser
  module Cutter
    describe Configuration do
      let(:config) { Laser::Cutter::Configuration.new(opts) }

      context 'option parsing' do
        let(:opts) { {"size" => "2x3x2/0.125/0.5", "inches" => true} }
        it 'should be able to parse size options' do
          expect(config.width).to eql(2.0)
          expect(config.height).to eql(3.0)
          expect(config.depth).to eql(2.0)
          expect(config.thickness).to eql(0.125)
          expect(config.notch).to eql(0.5)
        end
      end
      context '#validate' do
        let(:opts) { {"height" => "23"} }
        it 'should be able to validate missing options' do
          expect(config.height).to eql(23.0)
          expect { config.validate! }.to raise_error(RuntimeError)
        end
      end
      context '#list_page_sizes' do
        it 'should rely on existing external class' do
          klass = Module.const_get 'PDF::Core::PageGeometry::SIZES' rescue nil
          expect(klass).not_to be_nil
        end
        context 'formatting of output' do
          context 'when using inches' do
            let(:opts) { {"units" => "in"} }
            it 'should return the list in inches' do
              expect(config.all_page_sizes).to match %r(.*B10\:\s+1\.2\s+x\s+1\.7)
            end
          end
          context 'when using mm' do
            let(:opts) { {"units" => "mm"} }
            it 'should return the list in mm' do
              expect(config.all_page_sizes).to match %r(.*B10\:\s+31\.0\s+x\s+44\.0)
            end
          end
        end

      end
    end
  end
end
