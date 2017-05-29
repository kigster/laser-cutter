require 'json'
require 'laser_cutter'
require 'laser_cutter/errors'
require 'oj'

module LaserCutter
  module CLI
    class Serializer

      attr_accessor :file, :app

      def initialize(file, app)
        self.file = file
        self.app  = app
      end

      def deserialize
        string = if file.eql?('-')
                   app.stdin.read
                 elsif File.exist?(file)
                   File.read(file)
                 else
                   raise LaserCutter::Errors::FileNotFound, "Can't open file '#{file}' for reading."
                 end

        Oj.load(string || '{}', {})
      end

      def serialize(options)
        serialized = Oj.dump(options, {})
        if file.eql?('-')
          app.stdout.puts serialized
        elsif file
          File.open(file, 'w') do |f|
            f.puts serialized
          end
        else
          raise LaserCutter::Errors::FileNotFound, "Can't open file '#{file}' for reading."
        end
      end
    end
  end
end

