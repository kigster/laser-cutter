require_relative 'spec_helper'

module Laser
  module Cutter
    describe Configuration do
      let(:config) { Laser::Cutter::Configuration.new(opts)}

      context 'option parsing' do
        let(:opts) { { "size" => "2x3x2/0.125/0.5", "inches" => true} }
        it 'should be able to parse size options' do
          expect(config.width).to eql(2.0)
          expect(config.height).to eql(3.0)
          expect(config.depth).to eql(2.0)
          expect(config.thickness).to eql(0.125)
          expect(config.notch).to eql(0.5)
        end
      end
      context 'validate' do
        let(:opts)  {{ "height" => "23" }}
        it 'should be able to validate missing options' do
          expect(config.height).to eql(23.0)
          expect { config.validate! } .to raise_error(RuntimeError)
        end
      end

    end
  end
end
