# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Corners do
        include_context 'with a sloped box'

        subject(:corners) { described_class.new(profile: profile, width: width, notcher: notcher) }

        # A notch of 0.6 gives the width 9 notches, which begin with a tab.
        context 'when the back and the front strip begin with a tab along the width' do
          its(:front_bottom) { is_expected.to eq(:front) }
          its(:bottom_back) { is_expected.to eq(:back) }
          its(:back_top) { is_expected.to eq(:back) }
        end

        # A notch of 0.7 gives the width and the height 7 notches and the
        # front 3, and a tab in the middle of those begins with a hole.
        context 'when they begin with a hole on both edges at the corner' do
          let(:notch) { 0.7 }

          its(:front_bottom) { is_expected.to eq(:bottom) }
          its(:bottom_back) { is_expected.to eq(:bottom) }
          its(:back_top) { is_expected.to eq(:top) }
        end

        context 'without a front strip' do
          let(:front_height) { 0 }

          its(:front_bottom) { is_expected.to be_nil }
        end

        context 'without a top strip' do
          let(:slope) { Math.atan(2.0 / 5.0) * 180 / Math::PI }

          its(:back_top) { is_expected.to be_nil }
          its(:bottom_back) { is_expected.to eq(:back) }
        end
      end
    end
  end
end
