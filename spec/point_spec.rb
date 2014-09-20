require_relative 'spec_helper'

module Laser
  module Cutter
    module Geometry
      describe Point do
        let(:point1) { Point.new(1, 2) }

        context 'creation' do
          context 'from string' do
            it 'should instantiate correctly from a string' do
              expect(Point.new "1,2").to eql(point1)
            end
          end

          context 'from a hash' do
            it 'should instantiate correctly from a hash' do
              expect(Point.new(x: 1, y: 2)).to eql(point1)
            end
          end

        end
      end
    end
  end
end
