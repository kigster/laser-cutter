# frozen_string_literal: true

require 'stringio'
require 'tmpdir'

RSpec.describe Laser::Cutter::CLI::ConfigFile do
  describe '#read' do
    it 'reads STDIN for -' do
      stdin = $stdin
      $stdin = StringIO.new('{"width": 4}')
      expect(described_class.new('-').read).to eq('width' => 4)
    ensure
      $stdin = stdin
    end

    it 'raises on a file that is not JSON' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'broken.json')
        File.write(path, 'not json')
        expect { described_class.new(path).read }.to raise_error(Laser::Cutter::Error, /cannot read/)
      end
    end
  end

  describe '#write' do
    it 'raises when the file cannot be written' do
      expect { described_class.new('/nowhere/at/all.json').write({}, StringIO.new) }
        .to raise_error(Laser::Cutter::Error, /cannot write/)
    end
  end
end
