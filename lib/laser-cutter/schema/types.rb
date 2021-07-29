require 'dry/types'
require 'dry/struct'
require 'dry/schema'
require 'ruby-units'

module Laser
  module Cutter
    module Schema
      # noinspection RubyConstantNamingConvention
      module Types
        include Dry::Types()

        AcceptedUnits = %i(inches millimeters centimers meters yards feet)
        DefaultUnit   = :mm
        UnitType      = Instance(RubyUnits)

        UserInputSchema = Dry::Schema.Params do
          required(:width).filled(UnitType)
          required(:height).filled(UnitType)
          required(:depth).filled(UnitType)
          required(:thickness).filled(UnitType)

          optional(:notch).filled(UnitType)
          optional(:margin).filled(UnitType)
          optional(:padding).filled(UnitType)
          optional(:stroke).filled(UnitType)
          optinoal(:kerf).filled(UnitType)
        end


        class UserInput < Dry::Struct
          transform_keys(&:to_sym)

          attribute :width, Types::Params::Float.required
          attribute :height, Types::Params::Float.required
          attribute :depth, Types::Params::Float.required
          attribute :thickness, Types::Params::Float.required
          attribute :tab_width, Types::Params::Float.optional
          attribute :margin, Types::Params::Float.optional
          attribute :padding, Types::Params::Float.optional
          attribute :stroke, Types::Params::Float.optional
          attribute :kerf, Types::Params::Float.required
        end
      end
    end
  end
end
