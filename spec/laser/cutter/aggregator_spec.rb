# frozen_string_literal: true

module Laser
  module Cutter
    RSpec.describe Aggregator do
      def line(x1, y1, x2, y2)
        Geometry::Line.new(Geometry::Point[x1, y1], Geometry::Point[x2, y2])
      end

      def outline(*lines)
        described_class.new(lines).lines.map(&:to_s)
      end

      let(:short) { line(0, 0, 5, 0) }
      let(:long) { line(2, 0, 10, 0) }
      let(:vertical) { line(2, 0, 2, 12) }

      it 'keeps lines that share nothing, sorted' do
        expect(outline(vertical, short)).to eq([short, vertical].map(&:to_s))
      end

      it 'cancels two identical lines, whichever way each one points' do
        expect(outline(short, line(5, 0, 0, 0), vertical)).to eq([vertical.to_s])
      end

      it 'keeps a line drawn three times' do
        expect(outline(short, short, short)).to eq([short.to_s])
      end

      it 'keeps only the parts two overlapping lines do not share' do
        expect(outline(short, long, vertical)).to eq([line(0, 0, 2, 0), line(2, 0, 2, 12), line(5, 0, 10, 0)].map(&:to_s))
      end

      it 'joins lines that meet end to end' do
        expect(outline(line(0, 0, 2, 0), line(2, 0, 5, 0))).to eq([short.to_s])
      end

      it 'drops a line one other line covers whole, leaving the rest of it' do
        expect(outline(line(0, 0, 10, 0), line(2, 0, 5, 0))).to eq([line(0, 0, 2, 0), line(5, 0, 10, 0)].map(&:to_s))
      end

      it 'treats coordinates within the tolerance as the same' do
        expect(outline(line(0, 0, 5, 0), line(5, 0.0004, 10, 0.0004))).to eq([line(0, 0, 10, 0).to_s])
      end

      it 'keeps horizontal and vertical lines apart' do
        expect(outline(line(0, 0, 5, 0), line(0, 0, 0, 5)).size).to eq(2)
      end

      it 'passes a line on neither axis through' do
        skewed = line(0, 0, 3, 4)
        expect(outline(skewed, skewed)).to eq([skewed, skewed].map(&:to_s))
      end

      # A relative bound, since a shared CI runner can be several times slower
      # than a laptop: four times the lines take about four and a half times as
      # long when swept, and sixteen times as long when compared pairwise.
      it 'scales with n log n rather than the square of the line count' do
        seconds_for = lambda do |count|
          lines = Array.new(count) { |i| line(i, 0, i + 1.5, 0) }
          started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          described_class.new(lines)
          Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
        end

        expect(seconds_for.call(16_000) / seconds_for.call(4_000)).to be < 10
      end
    end
  end
end
