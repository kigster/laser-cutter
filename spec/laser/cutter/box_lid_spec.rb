# frozen_string_literal: true

require 'spec_helper'
require 'digest'

module Laser
  module Cutter
    # Every outline here is checked as a region, point by point, against a
    # description of the panel that owes nothing to the code that drew it.
    RSpec.describe Box, 'lid' do
      # Wide enough for a sample to land in every strip the kerf adds.
      let(:kerf) { 0.5 }
      let(:boxes) { Hash.new { |cache, (lid, cut)| cache[[lid, cut]] = build(lid, cut) } }

      def build(lid, cut)
        settings = dimensions.merge(units: 'mm', file: 'box.pdf', lid: lid, kerf: cut)
        Box.new(Configuration.new(settings)).tap(&:generate_notches)
      end

      # @return [Array<Array(Float, Float)>] points over a face and the margin around it
      def samples(face)
        Outline.samples(face, margin: 1.5 * dimensions[:thickness])
      end

      # @return [Boolean] whether a point is inside the named panel of a box cut without kerf
      def material?(lid, name, x, y)
        Outline.inside?(boxes[[lid, 0.0]].outlines[name], x, y)
      end

      def between?(value, from, to)
        from < value && value < to
      end

      # The region each panel should cover without kerf, given the box with a full lid.
      def expected?(lid, face, x, y)
        t = dimensions[:thickness]
        full = material?(:full, face.name, x, y)
        across = between?(x, face.p1.x, face.p2.x)
        case face.name
        when 'bottom' then full
        when 'front', 'left', 'right' then full && y > face.p1.y
        when 'back' then lid == :plain ? full && y < face.p2.y : full && (across || y < face.p2.y)
        when 'top'
          covered = between?(x, face.p1.x - t, face.p2.x + t) && between?(y, face.p1.y - t, face.p2.y + t)
          lid == :plain || y > face.p1.y ? covered : covered && (full || !across)
        end
      end

      shared_examples 'a box with a lid that lifts off' do |lid|
        let(:box) { boxes[[lid, 0.0]] }
        let(:cut) { boxes[[lid, kerf]] }

        it 'closes every outline' do
          expect([box, cut].flat_map { |b| b.outlines.values }).to all(satisfy { |lines| Outline.closed?(lines) })
        end

        it 'keeps every panel where the full lid has it' do
          expect(box.faces.map(&:to_a)).to eq(boxes[[:full, 0.0]].faces.map(&:to_a))
        end

        %w[top front back left right bottom].each do |name|
          it "cuts the #{name} panel to shape" do
            face = box.public_send(name)
            wrong = samples(face).reject { |x, y| material?(lid, name, x, y) == expected?(lid, face, x, y) }
            expect(wrong).to be_empty
          end

          it "grows the #{name} panel by half the kerf on every side" do
            wrong = samples(box.public_send(name)).reject do |x, y|
              Outline.inside?(cut.outlines[name], x, y) == Outline.within?(box.outlines[name], x, y, kerf / 2)
            end
            expect(wrong).to be_empty
          end
        end
      end

      shared_examples 'a box of any size' do
        describe 'with a plain lid' do
          it_behaves_like 'a box with a lid that lifts off', :plain

          it 'draws the lid as four lines' do
            expect(boxes[[:plain, kerf]].outlines['top'].size).to eq(4)
          end

          it 'sizes the lid to the outside of the walls, plus the kerf' do
            w, d, t = dimensions.values_at(:width, :depth, :thickness)
            lengths = boxes[[:plain, kerf]].outlines['top'].map(&:length).sort
            expect(lengths).to match_array([d, d, w, w].map { |side| be_within(1e-6).of(side + (2 * t) + kerf) })
          end
        end

        describe 'with a lid notched into the back wall' do
          it_behaves_like 'a box with a lid that lifts off', :back

          it 'leaves the back wall its notches under the lid' do
            back = boxes[[:back, 0.0]].back
            tabs = samples(back).count { |x, y| y > back.p2.y && material?(:back, 'back', x, y) }
            expect(tabs).to be_positive
          end
        end
      end

      context 'when the lid would own the corners anyway, and its notches start with a tab' do
        let(:dimensions) { { width: 50, height: 60, depth: 70, thickness: 6, notch: 10 } }

        it_behaves_like 'a box of any size'
      end

      context 'when the front would own the corners, and the notches of the lid start with a hole' do
        let(:dimensions) { { width: 40, height: 30, depth: 20, thickness: 3, notch: 5 } }

        it_behaves_like 'a box of any size'
      end

      context 'when the box is wide and its material thin' do
        let(:dimensions) { { width: 100, height: 80, depth: 60, thickness: 3, notch: 9 } }

        it_behaves_like 'a box of any size'
      end

      describe 'a full lid' do
        # Digests of the lines 2.0.0 drew, before the lid became an option.
        {
          [{ width: 50, height: 60, depth: 70, thickness: 6, notch: 10 }, 0.0] => '35d6a17c6f524b00',
          [{ width: 50, height: 60, depth: 70, thickness: 6, notch: 10 }, 0.1] => 'af287e64ac6a249f',
          [{ width: 40, height: 30, depth: 20, thickness: 3, notch: 6 }, 0.15] => '1aed155401688002',
          [{ width: 100, height: 80, depth: 60, thickness: 3, notch: 9 }, 0.1] => '06b3cbc4e66bd18b'
        }.each do |(dimensions, cut), digest|
          it "draws what 2.0.0 drew for #{dimensions.values.join('x')} with a #{cut} kerf" do
            lines = Box.new(Configuration.new(dimensions.merge(units: 'mm', file: 'box.pdf', kerf: cut))).generate_notches
            coordinates = lines.map { |l| [l.p1.x, l.p1.y, l.p2.x, l.p2.y].map { |v| v.round(6) + 0.0 } }.sort
            expect(Digest::SHA256.hexdigest(coordinates.inspect)[0, 16]).to eq(digest)
          end
        end

        it 'is the default' do
          expect(Box.new(Configuration.new(box: '4x3x2/0.125', file: 'box.pdf')).lid).to eq(:full)
        end
      end
    end
  end
end
