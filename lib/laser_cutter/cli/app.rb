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
      attr_reader :options, :parser, :config

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

        @options = Hashie::Mash.new

        @parser = LaserCutter::CLI::Parser.new(@options)
        @parser.parse(argv.dup)

        process_options!

        @config = options_to_config
      end

      def process_options!
        print_and_exit(:help, :examples, :version)
      end

      private

      def print_and_exit(*keys)
        keys.each do |key|
          if options[key]
            stdout.puts options[key]
            terminate
          end
        end
      end

      # This can be overridden in tests
      def terminate
        exit
      end

      def error(e)
        self.stderr.puts "Whoops, #{e}".red
        self.stderr.puts 'Try --help or --examples for more info...'.yellow
      end

      def options_to_config
        options.merge!(Serializer.new(options.read_file, self).deserialize) if options.read_file

        config = LaserCutter::Config.new(options.to_hash)
        errors = config.validate!
        unless errors.empty?
          error(errors.map(&:full_messages).join("\n"))
        end

        Serializer.new(options.write_file, app).serialize(options) if options.write_file

        config
      end
    end
  end
end
