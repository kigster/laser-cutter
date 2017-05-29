require 'spec_helper'

RSpec.describe LaserCutter::CLI::Parser do
  let(:argv) { [] }
  let(:options) { Hashie::Mash.new }
  subject(:parser) { described_class.new(options) }

  before { parser.parse(*argv) }

  context '--help' do
    let(:argv) { %w[--help] }
    its(:options) { should_not be_empty }
    it('should have :help with contents') { expect(subject.options[:help]).to eq(parser.to_s) }
    it('should have :help') { expect(subject.options[:help]).to_not be_blank }
    it('should have :help') { expect(subject.options[:help].to_s).to match /.*Convert to 'mm'.*/ }
  end
end
