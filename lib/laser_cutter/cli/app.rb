require 'optparse'
require 'colored2'
require 'colored2/version'
require 'json'
require 'hashie/mash'
require 'laser_cutter'
require 'laser_cutter/cli/serializer'
require 'laser_cutter/cli/banner'

module LaserCutter
  module CLI
    class App

      attr_accessor :argv, :stdin, :stdout, :stderr, :kernel
      attr_accessor :options

      def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
        self.stdin  = stdin
        self.stdout = stdout
        self.stderr = stderr
        self.kernel = kernel

        if argv.nil? || argv.empty?
          self.argv = %w[--help]
        else
          self.argv = argv.dup
        end

        self.options = Hashie::Mash.new

        parser.parse(argv.dup)
      end

      def parser
        @parser ||= Parser.new(options)
      end

      def error(e)
        STDERR.puts "Whoops, #{e}".red
        STDERR.puts 'Try --help or --examples for more info...'.yellow
      end

      def options_to_config
        if options.read_file
          options.merge!(Serializer.new(options.read_file, self).deserialize)
        end

        config = LaserCutter::Config.new(options.to_hash)
        config.validate!

        if options.write_file
          Serializer.new(options.write_file, app).serialize(options)
        end

        config
      end
    end
  end
end
