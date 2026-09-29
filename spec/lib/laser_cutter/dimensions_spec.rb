# frozen_string_literal: true

require 'spec_helper'
module Laser
  module Cutter
    module Geometry
      RSpec.describe Dimensions do
        let(:dim1) { Dimensions.new(20, 10, 50) }

        context 'creation' do
          context 'from string' do
            let(:dim2) { Dimensions.new "20x10x50" }

            it 'instantiates correctly from a string' do
              expect(dim2).not_to be_nil
              expect(dim2).to eql(dim1)
            end
          end

          context 'from hash' do
            it 'instantiates correctly from a hash' do
              expect(Dimensions.new(h: 10, w: 20, d: 50)).to eql(dim1)
            end
          end
        end
      end
    end
  end
end
