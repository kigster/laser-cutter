require 'hashie/mash'
require 'prawn/measurement_extensions'
require 'pdf/core/page_geometry'

module Laser
  module Cutter
    class MissingOption < RuntimeError
    end
    class Configuration < Hashie::Mash
      DEFAULTS = {
          units: 'mm',
          page_size: 'LETTER',
          page_layout: 'portrait'
      }

      UNIT_SPECIFIC_DEFAULTS = {
          'mm' => {
              margin: 5,
              padding: 5,
              stroke: 0.0254,
          },
          'in' => {
              margin: 0.125,
              padding: 0.1,
              stroke: 0.001,
          }
      }

      SIZE_REGEXP = /[\d\.]+x[\d\.]+x[\d\.]+\/[\d\.]+\/[\d\.]+/

      FLOATS = %w(width height depth thickness notch margin padding stroke)
      NON_ZERO = %w(width height depth thickness stroke)
      REQUIRED = %w(width height depth thickness notch file)

      def initialize(options = {})
        options.delete_if { |k, v| v.nil? }
        if options['units'] && !UNIT_SPECIFIC_DEFAULTS.keys.include?(options['units'])
          options.delete('units')
        end
        self.merge!(DEFAULTS)
        self.merge!(options)
        if self['size'] && self['size'] =~ SIZE_REGEXP
          dim, self['thickness'], self['notch'] = self['size'].split('/')
          self['width'], self['height'], self['depth'] = dim.split('x')
          delete('size')
        end
        FLOATS.each do |k|
          self[k] = self[k].to_f if (self[k] && self[k].is_a?(String))
        end
        self.merge!(UNIT_SPECIFIC_DEFAULTS[self['units']].merge(self))
      end

      def validate!
        missing = []
        REQUIRED.each do |k|
          missing << k if self[k].nil?
        end
        unless missing.empty?
          raise MissingOption.new("#{missing.join(', ')} #{missing.size > 1 ? 'are' : 'is'} required, but missing.")
        end

        NON_ZERO.each do |k|
          if self[k] == 0
            raise MissingOption.new("#{missing.join(', ')} #{missing.size > 1 ? 'are' : 'is'} required, but is zero.")
          end
        end
      end

      def page_size_values
        unit = 1.0 / 72.0 # PDF units per inch
        multiplier = (self.units == 'in') ? 1.0 : 25.4
        h = PDF::Core::PageGeometry::SIZES
        array = []
        h.keys.sort.each do |k|
          array << [ k,
                      multiplier * h[k][0].to_f * unit,
                      multiplier * h[k][1].to_f * unit ]
        end
        array
      end

      def all_page_sizes
        output = ""
        page_size_values.each do |k|
          output << sprintf("\t%10s:\t%6.1f x %6.1f\n", *k)
        end
        output
      end

      def change_units(new_units)
        return if (self.units.eql?(new_units) || !UNIT_SPECIFIC_DEFAULTS.keys.include?(new_units))
        k = (self.units == 'in') ? 25.4 : 0.039370079
        FLOATS.each do |field|
          self.send("#{field}=".to_sym, (self.send(field.to_sym) * k).round(5))
        end
        self.units = new_units
      end
    end
  end
end
