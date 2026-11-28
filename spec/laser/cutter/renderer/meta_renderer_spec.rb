# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Renderer
      RSpec.describe MetaRenderer do
        subject(:renderer) { described_class.new(Configuration.new(settings)) }

        let(:settings) { { box: '4x3x5/0.125', file: 'box.pdf' } }

        def pages(settings) = LayoutRenderer.new(Configuration.new(settings)).document.scan(%r{/Type /Page\b}).size

        it 'prints the settings of the box, in order' do
          expect(renderer.fields.keys).to eq(%i[units width height depth thickness notch lid kerf stroke padding margin page_size])
        end

        it 'calls a page fitted to the box custom, and leaves its layout out' do
          expect(renderer.fields.slice(:page_size, :page_layout)).to eq(page_size: 'custom')
        end

        it 'is as tall as its banner and one line for each setting' do
          expect(renderer.enclosure.h).to be_within(1e-9).of(55 + (12 * 8.2) + 4)
        end

        it 'fits on the page of the box' do
          expect(pages(settings)).to eq(1)
        end

        context 'with a page size' do
          let(:settings) { super().merge(page_size: 'A3', page_layout: 'landscape') }

          it 'prints the size and the layout' do
            expect(renderer.fields).to include(page_size: 'A3', page_layout: 'landscape')
          end

          it 'fits on the page' do
            expect(pages(settings)).to eq(1)
          end
        end

        context 'with a sloped box' do
          let(:settings) { super().merge(slope: 45, front_height: 1) }

          it 'prints the front height and the slope after the depth' do
            expect(renderer.fields.keys[3, 3]).to eq(%i[depth front_height slope])
          end

          it 'grows by two lines' do
            expect(renderer.enclosure.h).to be_within(1e-9).of(55 + (14 * 8.2) + 4)
          end

          it 'fits on the page of the box' do
            expect(pages(settings)).to eq(1)
          end
        end
      end
    end
  end
end
