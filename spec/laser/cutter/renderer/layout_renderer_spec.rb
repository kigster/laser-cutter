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
