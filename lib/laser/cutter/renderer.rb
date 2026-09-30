# frozen_string_literal: true

module Laser
  module Cutter
    module Renderer
      # The renderer that writes each output format.
      FORMATS = {
        'pdf' => 'LayoutRenderer',
        'svg' => 'SvgRenderer'
      }.freeze

      # @param format [String, Symbol] 'pdf' or 'svg', in either case
      # @param config [Configuration]
      # @return [LayoutRenderer, SvgRenderer]
      # @raise [Error] for a format nothing here writes
      def self.for(format, config)
        name = FORMATS.fetch(format.to_s.downcase) do
          raise Error, "unknown format #{format.inspect}, expected one of: #{FORMATS.keys.join(', ')}"
        end
        const_get(name).new(config)
      end
    end
  end
end
