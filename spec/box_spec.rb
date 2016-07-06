require 'spec_helper'
require 'laser-cutter/strategy/line_joiner'
module Laser
  module Cutter
    module Model
      describe Box do
        let(:depth) { 70 }
        let(:thickness) { 6 }
        let(:hash) { {
          file:    'boo.pdf',
          width:   50,
          height:  60,
          depth:   depth,
          margin:  5,
          padding: 3,
          units:   'mm' } }

        let(:box1_hash) { hash.merge(thickness: thickness, notch: 10) }
        let(:box2_hash) { hash.merge(thickness: thickness) }

        let(:config) { Laser::Cutter::Model::Configuration.new(hash) }

        let(:box1_config) { Laser::Cutter::Model::Configuration.new(box1_hash) }
        let(:box2_config) { Laser::Cutter::Model::Configuration.new(box2_hash) }

        let(:box1) { Box.new(box1_config).construct }
        let(:box2) { Box.new(box2_config).construct }

        context '#initialize' do
          it 'should initialize with passed in parameters' do
            expect(box1.w).to eq(50.0)
            expect(box1.thickness).to eq(6.0)
            expect(box1.notch).to eq(10.0)
          end

          it 'should initialize with default notch' do
            expect(box2.notch).to eq(depth / 5)
          end
        end

        context '#notches' do
          it 'should generate notches' do
            expect(box1.notches).to_not be_nil
            expect(box1.notches.values.flatten.size).to eql(368)
          end

          context 'when notches are generated for a face' do
            subject { Laser::Cutter::Strategy::LineJoiner.new(box1.notches[:top]).lines }

            it 'should form a contiguous polygon' do
              subject.each_with_index do |line, index|
                if index < subject.size - 1
                  puts "#{line}\n#{subject[index + 1].reverse}\n\n"
                  expect(line.p2).to eql(subject[index + 1].p1)
                end
              end
            end
          end

          it 'should properly calculate enclosure' do
            expect(box1.enclosure.to_a.flatten.map(&:round)).to eql([0, 0, 232, 317])
            expect(box2.enclosure.to_a.flatten.map(&:round)).to eql([0, 0, 232, 317])
          end
        end

      end
    end
  end
end
