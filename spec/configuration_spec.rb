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
        context 'missing options' do
        let(:opts) { {"height" => "23"} }
        it 'should be able to validate missing options' do
          expect(config.height).to eql(23.0)
          expect { config.validate! }.to raise_error(Laser::Cutter::MissingOption)
        end
        end
        context 'zero options' do
        let(:opts) { {"size" => "2.0x0.0x2/0.125/0.5", "inches" => true, 'file' => '/tmp/a'} }
        it 'should be able to validate missing options' do
          expect(config.height).to eql(0.0)
          expect { config.validate! }.to raise_error(Laser::Cutter::ZeroValueNotAllowed)
        end
        end
      end
      context '#list_page_sizes' do
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

      context "#default to mm for incorrect units" do
        let(:opts) { {"size" => "2x3x2/0.125/0.5", "units" => 'xx'} }
        it 'should default to millimeters' do
          expect(config.units).to eql('mm')
        end
      end

      context "#change_units" do
        context "from inches" do
          let(:opts) { {"size" => "2.0x3x2/0.125/0.5", 'padding' => '4.2', "units" => 'in'} }
          it "should convert to mm" do
            expect(config.width).to eql(2.0)
            config.change_units('in')
            expect(config.width).to eql(2.0)
            config.change_units('mm')
            expect(config.width).to eql(50.8)
            expect(config.padding).to eql(106.68)
            expect(config.units).to eql('mm')
          end
        end
        context "from mm" do
          let(:opts) { {"size" => "20.0x30.0x40.0/5/5", 'margin' => '10.0', "units" => 'mm'} }
          it "should convert to inches" do
            expect(config.width).to eql(20.0)
            config.change_units('mm')
            expect(config.width).to eql(20.0)
            config.change_units('in')
            expect(config.width).to be_within(0.00001).of(0.787401575)
            expect(config.margin).to be_within(0.00001).of(0.393700787)
            expect(config.units).to eql('in')
          end
        end
      end
    end
  end
end
