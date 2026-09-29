# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Notching
      RSpec.describe Edge do
        # When the notch divides the side exactly, length / notch lands on a
        # whole number, and float noise in the edge coordinates used to tip
        # #ceil either way, so panels meeting at one joint disagreed.
        context 'when the notch divides the side exactly' do
          let(:outside) { Geometry::Line.new(Geometry::Point[0, 0], Geometry::Point[0, 3.25]) }

          [2.9999999999999991, 3.0, 3.0000000000000013].each do |length|
            it "gives a #{length.inspect}-long side 7 notches" do
              inside = Geometry::Line.new(Geometry::Point[0.125, 0.125], Geometry::Point[0.125, 0.125 + length])
              edge = described_class.new(outside, inside, notch_width: 0.5, thickness: 0.125)
              expect(edge.notch_count).to eq(7)
            end
          end
        end

        context 'left vertical side' do
          let(:notch_width) { 2 }
          let(:inside) { Geometry::Line.new(Geometry::Point[1, 1], Geometry::Point[1, 9]) }
          let(:outside) { Geometry::Line.new(Geometry::Point[0, 0], Geometry::Point[0, 10]) }
          let(:edge) {
            Notching::Edge.new(inside,
                               outside,
                               center_out:   true,
                               fill_corners: true,
                               notch_width:  notch_width,
                               kerf:         0.02,
                               thickness:    1)
          }

          it 'creates a node correctly' do
            expect(inside.length).to eql(8.0)
            expect(outside.length).to eql(10.0)
            expect(edge.center_out).to be_truthy
            expect(edge.kerf).to be_within(0.0001).of(0.02)
            expect(edge.thickness).to be_within(0.0001).of(1)
            expect(edge.notch_width).to be_within(notch_width / 3.0).of(notch_width)
          end

          it 'calculates notch width correctly' do
            expect(inside.length).to eql(8.0)
            expect(outside.length).to eql(10.0)
            expect(edge.center_out).to be_truthy

            expect(edge.kerf).to be_within(0.0001).of(0.02)
            expect(edge.thickness).to be_within(0.0001).of(1)
          end

          it 'correctlies calculate v1 and v2' do
            expect(edge.v1.to_a).to eql([1.0, 1.0])
            expect(edge.v2.to_a).to eql([1.0, -1.0])
          end
        end
      end
    end
  end
end
