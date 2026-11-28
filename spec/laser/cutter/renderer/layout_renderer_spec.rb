# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

module Laser
  module Cutter
    module Renderer
      RSpec.describe LayoutRenderer do
        describe '#render' do
          let(:renderer) { LayoutRenderer.new(config) }
          let(:dir) { Dir.mktmpdir }
          let(:file) { File.join(dir, 'box.pdf') }

          after { FileUtils.remove_entry(dir) }

          def render_file(filename)
            config.validate!
            renderer.render
            expect(File.binread(filename)).to start_with('%PDF')
          end

          context 'with a slope' do
            let(:config) do
              Laser::Cutter::Configuration.new('box' => '4x3x5/0.25/0.6', 'slope' => '45', 'front_height' => '1', 'file' => file)
            end

            it 'is able to generate a PDF file' do
              render_file file
            end

            it 'draws the seven panels of a sloped box' do
              expect(renderer.total).to eq(Laser::Cutter::Sloped::Box.new(config).notches.size)
            end

            it 'draws them twice with the outline without kerf' do
              expect(LayoutRenderer.new(Laser::Cutter::Configuration.new(config.to_hash.merge(debug: true))).total).to eq(2 * renderer.total)
            end
          end

          context 'metric' do
            let(:config) {
              Laser::Cutter::Configuration.new(
                'width'     => 50,
                'height'    => 60,
                'depth'     => 20,
                'thickness' => 6,
                'margin'    => 5,
                'padding'   => 3,
                'notch'     => 10,
                'file'      => file
              )
            }

            it 'is able to generate a PDF file' do
              render_file file
            end
          end

          context 'imperial' do
            context 'margins and padding provided' do
              let(:config) {
                Laser::Cutter::Configuration.new(
                  'width'     => 2.5,
                  'height'    => 3.5,
                  'depth'     => 2.0,
                  'thickness' => 0.125,
                  'margin'    => 0,
                  'padding'   => 0.125,
                  'notch'     => 0.25,
                  'file'      => file,
                  'units'     => 'in'
                )
              }

              it 'is able to generate a PDF file' do
                render_file file
              end
            end

            context 'margins and padding are defaults' do
              let(:config) {
                Laser::Cutter::Configuration.new(
                  'width'     => 2.5,
                  'height'    => 2,
                  'depth'     => 2.0,
                  'thickness' => 0.125,
                  'notch'     => 0.25,
                  'file'      => file,
                  'units'     => 'in'
                )
              }

              it 'is able to generate a PDF file' do
                render_file file
              end
            end
          end
        end
      end
    end
  end
end
