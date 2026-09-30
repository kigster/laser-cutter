# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      # A configuration saved as JSON. The path '-' stands for STDIN when
      # reading, and for the command's own output when writing.
      class ConfigFile
        STDIO = '-'

        # @param path [String]
        def initialize(path)
          @path = path
        end

        # @return [Hash{String => Object}]
        # @raise [Error] when the file is missing, or is not JSON
        def read
          JSON.parse(@path == STDIO ? $stdin.read : File.read(@path))
        rescue SystemCallError, JSON::ParserError => e
          raise Error, "cannot read the configuration from #{@path}: #{e.message}"
        end

        # @param settings [Hash]
        # @param out [IO] where '-' writes to
        # @raise [Error] when the file cannot be written
        def write(settings, out)
          json = JSON.pretty_generate(settings)
          @path == STDIO ? out.puts(json) : File.write(@path, "#{json}\n")
        rescue SystemCallError => e
          raise Error, "cannot write the configuration to #{@path}: #{e.message}"
        end
      end
    end
  end
end
