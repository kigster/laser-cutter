require 'hashie/mash'
require 'prawn/measurement_extensions'


module Laser
  module Cutter
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

      FLOATS   = %w(width height depth thickness notch margin padding stroke)
      REQUIRED = %w(width height depth thickness notch file)

      def initialize(options = {})
        options.delete_if{|k,v| v.nil?}
        self.merge!(DEFAULTS)
        self.merge!(options)
        if self['size'] && self['size'] =~ SIZE_REGEXP
          dim, self['thickness'], self['notch'] = self['size'].split('/')
          self['width'],self['height'],self['depth'] = dim.split('x')
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
        raise "#{missing.join(', ')} #{missing.size > 1 ? 'are' : 'is'} required, but missing." unless missing.empty?
      end
    end
  end
end
