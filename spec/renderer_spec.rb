require_relative 'spec_helper'

module Laser
  module Cutter
    module Renderer
      describe 'BoxRenderer' do
        context '#render' do
          let(:box) { Laser::Cutter::Box.new(config) }
          let(:renderer) { LayoutRenderer.new(config) }
          let(:file) { File.expand_path("../../laser-cutter-pdf-test.#{$$}.pdf", __FILE__) }

          def render_file filename
            expect(!File.exists?(filename))
            renderer.render
            expect(File.exist?(filename))
            expect(File.size(filename) > 0)
          ensure
            File.delete(filename)
            expect(!File.exists?(filename))
          end

          context 'metric' do
            let(:config) { Laser::Cutter::Configuration.new(
                'width' => 50, 'height' => 60, 'depth' => 20, 'thickness' => 6,
                'margin' => 5, 'padding' => 3, 'notch' => 10, 'file' => file) }

            it 'should be able to generate a PDF file' do
              render_file file
            end
          end

          context 'imperial' do
            context 'margins and padding provided' do
              let(:config) { Laser::Cutter::Configuration.new(
                  'width' => 2.5, 'height' => 3.5, 'depth' => 2.0, 'thickness' => 0.125,
                  'margin' => 0, 'padding' => 0.125, 'notch' => 0.25, 'file' => file,
                  'units' => 'in') }

              it 'should be able to generate a PDF file' do
                render_file file
            end
            end

            context 'margins and padding are defaults' do
              let(:config) { Laser::Cutter::Configuration.new(
                  'width' => 2.5, 'height' => 2, 'depth' => 2.0, 'thickness' => 0.125,
                  'notch' => 0.25, 'file' => file, 'units' => 'in') }

              it 'should be able to generate a PDF file' do
                render_file file
              end
            end
          end

        end
      end

    end
  end
end
