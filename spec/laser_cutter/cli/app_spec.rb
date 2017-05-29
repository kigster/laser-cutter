require 'spec_helper'

RSpec.describe LaserCutter::CLI::App do
  let(:argv) { [] }
  subject(:app) { described_class.new(argv) }

  context '--help' do
    let(:argv) { %w[--help] }
    its(:options) { should_not be_empty }
  end
end
