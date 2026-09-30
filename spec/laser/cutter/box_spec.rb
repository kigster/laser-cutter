# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    RSpec.describe Box do
      let(:config) { { 'width' => 50, 'height' => 60, 'depth' => 70, 'margin' => 5, 'padding' => 3, 'units' => 'mm' } }
      let(:box1) { Box.new(config.merge('thickness' => 6, 'notch' => 10)) }
      let(:box2) { Box.new(config.merge('thickness' => 6, )) }

      describe '#initialize' do
        it 'initializes with passed in parameters' do
          expect(box1.w).to eq(50.0)
          expect(box1.thickness).to eq(6.0)
          expect(box1.notch_width).to eq(10.0)
        end

        it 'initializes with default notch' do
          expect(box2.notch_width).to eq(70.0 / 5.0)
        end
      end

      describe 'notch counts across joints' do
        # Sides meeting at a joint share a nominal length, and must get the
        # same number of notches or the two panels do not fit together.
        [0.0, 0.0024].each do |kerf|
          it "agree on a 4x3x2 box with a 0.5 notch and a #{kerf} kerf" do
            edges = []
            allow(Notching::Edge).to receive(:new).and_wrap_original do |original, *args|
              original.call(*args).tap { |edge| edges << edge }
            end
            Box.new(Configuration.new(width: 4, height: 3, depth: 2, thickness: 0.125,
                                      notch: 0.5, kerf: kerf, file: 'box.pdf')).generate_notches

            counts = edges.group_by { |edge| edge.inside.length.round(1) }
                          .transform_values { |group| group.map(&:notch_count).uniq }
            expect(counts).to eq(4.0 => [9], 3.0 => [7], 2.0 => [5])
          end
        end
      end

      describe '#notches' do
        before do
          box1.generate_notches
          box2.generate_notches
        end

        it 'generates notches' do
          expect(box1.notches).not_to be_nil
          expect(box1.notches.size).to eql(368)
        end

        it 'properlies calculate enclosure' do
          expect(box1.enclosure.to_a.flatten.map(&:round)).to eql([0, 0, 232, 317])
          expect(box2.enclosure.to_a.flatten.map(&:round)).to eql([0, 0, 232, 317])
        end
      end
    end
  end
end
