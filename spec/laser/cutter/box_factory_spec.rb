# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    RSpec.describe BoxFactory do
      let(:settings) { { width: 4, height: 3, depth: 5, thickness: 0.25, units: 'in', file: 'box.pdf' } }

      it 'builds the box with six panels for settings without a slope' do
        expect(described_class.for(Configuration.new(settings))).to be_a(Box)
      end

      it 'builds a sloped box for settings with a slope' do
        expect(described_class.for(Configuration.new(settings.merge(slope: 45, front_height: 1)))).to be_a(Sloped::Box)
      end
    end
  end
end
