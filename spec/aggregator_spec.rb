require_relative 'spec_helper'

module Laser
  module Cutter
    describe Aggregator do
      let(:p1) { Geometry::Point[0,  0] }
      let(:p2) { Geometry::Point[2,  0] }
      let(:p3) { Geometry::Point[5,  0] }
      let(:p4) { Geometry::Point[10, 0] }

      let(:l1) { Geometry::Line.new(p1, p3) }
      let(:l2) { Geometry::Line.new(p2, p4) }
      let(:lines) { [ l1, l2 ]}
      let(:aggregator) { Aggregator.new(lines) }

      context '#initialize' do
        it 'should initialize with passed in parameters' do
          expect(aggregator.lines.size).to eql(2)
        end
      end

    end
  end
end
