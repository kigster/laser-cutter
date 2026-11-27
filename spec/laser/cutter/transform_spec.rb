# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Geometry
      RSpec.describe Transform do
        def point(x, y) = Point[x, y]

        context 'with no turn and no move' do
          subject(:transform) { described_class.new(point(0, 0), 0) }

          it 'leaves a point where it is' do
            expect(transform.apply(point(3, 4))).to eql(point(3, 4))
          end
        end

        context 'along an upward run from {1,1}' do
          subject(:transform) { described_class.along(point(1, 1), point(1, 5)) }

          its(:angle) { is_expected.to be_within(1e-9).of(Math::PI / 2) }

          it 'maps the local x axis onto the run' do
            expect(transform.apply(point(4, 0))).to eql(point(1, 5))
          end

          it 'maps the local y axis to the left of the run' do
            expect(transform.apply(point(0, 1))).to eql(point(0, 1))
          end

          it 'maps both ends of a line' do
            line = transform.apply(Line.new(point(0, 0), point(2, 1)))
            expect([line.p1, line.p2]).to eql([point(1, 1), point(0, 3)])
          end
        end

        it 'keeps lengths' do
          transform = described_class.along(point(2, 3), point(5, 7))
          expect(transform.apply(Line.new(point(0, 0), point(5, 0))).length).to be_within(1e-9).of(5)
        end

        it 'refuses what it cannot move' do
          expect { described_class.new(point(0, 0), 0).apply(:rect) }.to raise_error(ArgumentError)
        end

        it 'is frozen' do
          expect(described_class.new(point(0, 0), 1)).to be_frozen
        end
      end
    end
  end
end
