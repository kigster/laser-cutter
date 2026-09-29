# frozen_string_literal: true

module Laser
  module Cutter
    class PageManager < Struct.new(:units)
      SIZES = PDF::Core::PageGeometry::SIZES.clone.freeze

      def all_page_sizes
        output = +""
        page_size_values.each do |k|
          output << sprintf("\t%10s:\t%6.1f x %6.1f\n", *k)
        end
        output
      end

      # if from_units is nil, we expect it to be in dots per inch (default
      # measurements for Prawn
      def value_from_units(value, from_units = nil)
        multiplier = if from_units.nil?
                       if units.eql?('in')
                         1.0 / 72.0 # PDF units per inch
                       else
                         25.4 * 1.0 / 72.0
                       end
                     elsif units.eql?(from_units)
                       1.0
                     elsif units.eql?('in') && from_units.eql?('mm')
                       (1.0 / 25.4)
                     else
                       25.4
                     end
        value.to_f * multiplier
      end

      def page_size_values
        h = Hashie::Mash.new(SIZES)
        h.keys.sort.map do |k|
          [k, value_from_units(h[k][0].to_f), value_from_units(h[k][1].to_f)]
        end
      end
    end
  end
end
