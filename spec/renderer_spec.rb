require_relative 'spec_helper'

module Laser
  module Cutter
    module Renderer
      describe 'BoxRenderer' do
        context '#render' do
          let(:box) { Laser::Cutter::Box.new(Geometry::Dimensions.new("50x40x20"), 3, 9) }
          let(:renderer) { BoxRenderer.new(box) }
          let(:file) { File.expand_path("../../laser-cutter-pdf-test.#{$$}.pdf", __FILE__)}

          it 'should be able to generate a PDF file' do
            expect(!File.exists?(file))
            renderer.render(nil, file)
            expect(File.exist?(file))
            expect(File.size(file) > 0)
            File.delete(file)
            expect(!File.exists?(file))
          end
        end

      end
    end

  end
end
