require 'hashie/mash'
require 'hashie/extensions/symbolize_keys'
require 'prawn/measurement_extensions'
require 'pdf/core/page_geometry'

require 'laser-cutter/strategy/notch_length'
require 'laser-cutter/helpers/units'

module Laser
  module Cutter
    module Model
      class MissingOption < RuntimeError;
      end
      class ZeroValueNotAllowed < MissingOption;
      end

      class Configuration < Hashie::Mash
        include Hashie::Extensions::SymbolizeKeys

        DEFAULTS = {
          units:             :in,
          page_layout:       :portrait,
          print_metadata:    true,
          auto_notch_method: :from_sides
        }

        DEFAULT_FLOATS = {
          :in => {
            kerf:    0.0035, # smallest kerf for thin material, usually it's more than that.
            margin:  0.1250,
            padding: 0.1000,
            stroke:  0.0010,
          }
        }

        UNITS = Laser::Cutter::Helpers::Units

        DEFAULT_FLOATS[:mm] = DEFAULT_FLOATS[:in].map { |k, v| [k, UNITS.from.inches(v)] }.to_h

        SIZE_REGEXP = /[\d\.]+x[\d\.]+x[\d\.]+\/[\d\.]+(\/[\d\.]+)?/

        FLOATS   = %i(width height depth thickness notch margin padding stroke kerf)
        NON_ZERO = %i(width height depth thickness stroke)
        REQUIRED = %i(width height depth thickness notch file)

        SYMBOLIZE = %i(units page_layout notch_strategy)

        def initialize(options = {})
          options.delete_if { |k, v| v.nil? }

          merge!(DEFAULTS.merge(options))

          SYMBOLIZE.each { |k| self[k] = self[k].to_sym if self[k] }

          if self[:units] && !DEFAULT_FLOATS.keys.include?(self[:units])
            self[:units] = :in
          end

          if self[:size] =~ SIZE_REGEXP
            dim, self[:thickness], self[:notch]       = self[:size].split('/')
            self[:width], self[:height], self[:depth] = dim.split('x')
            delete(:size)
          end

          self.merge!(DEFAULT_FLOATS[self[:units]].merge(self.to_hash))

          FLOATS.each do |k|
            self[k] = self[k].to_f if (self[k] && self[k].is_a?(String))
          end

          if self[:notch].nil?
            self[:notch] = Laser::Cutter::Strategy::NotchLength::FromSides.new(self).len
          end
        end

        def validate!
          missing = []
          REQUIRED.each { |k| missing << k if self[k].nil? }
          raise MissingOption.new("#{missing.join(', ')} #{missing.size > 1 ? 'are' : 'is'} required, but missing.") unless missing.empty?

          zeros = []
          NON_ZERO.each { |k| zeros << k if self[k] == 0 }
          raise ZeroValueNotAllowed.new("#{zeros.join(', ')} #{zeros.size > 1 ? 'are' : 'is'} required, but is zero.") unless zeros.empty?
        end

        def longest_side
          (self[:width] && self[:height] && self[:depth]) ? [self[:width], self[:height], self[:depth]].max() : 0
        end

        def change_units(new_units)
          new_units = new_units.to_sym
          return if (self.units.eql?(new_units) || !DEFAULT_FLOATS.keys.include?(new_units))
          k = (self.units == :in) ? UNITS.from.inches(1.0) : UNITS.from.millimeters(1.0)
          FLOATS.each do |field|
            next if self.send(field.to_sym).nil?
            self.send("#{field}=".to_sym, (self.send(field.to_sym) * k).round(5))
          end
          self[:units]= new_units
        end
      end
    end
  end
end
