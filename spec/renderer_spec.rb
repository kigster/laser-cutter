require_relative 'spec_helper'

module Laser
  module Cutter
    module Renderer
      describe 'BoxRenderer' do
        context '#render' do
          let(:box) { Box.new(Geometry::Dimensions.new("10x50x30"), 4, 4) }
          let(:renderer) { BoxRenderer.new(box) }
          xit 'should layout correctly' do

          end

          xit 'should save a PDF file' do
            renderer.render
            `open ./output.pdf`
          end
        end

      end
    end

  end
end
