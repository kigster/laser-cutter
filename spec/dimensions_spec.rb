require_relative 'spec_helper'
module Laser
  module Cutter
    module Geometry

      describe Dimensions do
        let(:dim1) { Dimensions.new(20, 10, 50) }

        context 'creation' do
          context 'from string' do
            let(:dim2) { Dimensions.new "20x10x50" }
            it 'should instantiate correctly from a string' do
              expect(dim2).to_not be_nil
              expect(dim2).to eql(dim1)
            end
          end

          context 'from hash' do
            it 'should instantiate correctly from a hash' do
              expect(Dimensions.new(h: 10, w: 20, d: 50)).to eql(dim1)
            end
          end
        end
      end
    end
  end
end
