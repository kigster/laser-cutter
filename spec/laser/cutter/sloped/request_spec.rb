# frozen_string_literal: true

require 'spec_helper'

module Laser
  module Cutter
    module Sloped
      RSpec.describe Request do
        let(:box) { { depth: 5, height: 3, thickness: 0.25 } }

        def validate(**settings) = described_class.validate!(box.merge(settings))

        it 'passes settings that ask for no slope' do
          expect(validate(lid: 'back')).to be_nil
        end

        it 'returns the profile of a sloped box' do
          expect(validate(slope: 45, front_height: 1)).to be_a(Profile).and have_attributes(top_depth: be_within(1e-9).of(3.0))
        end

        it 'takes a front height of zero' do
          expect(validate(slope: 45, front_height: 0)).not_to be_front_strip
        end

        it 'takes the lid as a String or a Symbol' do
          expect([validate(slope: 45, front_height: 1, lid: 'plain'), validate(slope: 45, front_height: 1, lid: :full)]).to all(be_a(Profile))
        end

        it 'raises MissingOption for a slope without a front height' do
          expect { validate(slope: 45) }.to raise_error(MissingOption, /front_height is required with slope/)
        end

        it 'raises InvalidOption for a front height without a slope' do
          expect { validate(front_height: 1) }.to raise_error(InvalidOption, /needs a slope/)
        end

        it 'raises InvalidOption for a lid notched into the back wall' do
          expect { validate(slope: 45, front_height: 1, lid: 'back') }
            .to raise_error(InvalidOption, /lid cannot be "back" with a slope, but must be one of: full, plain/)
        end

        it 'raises InvalidOption for numbers that do not make the shape' do
          expect { validate(slope: 10, front_height: 1) }.to raise_error(InvalidOption, /needs a depth/)
        end
      end
    end
  end
end
