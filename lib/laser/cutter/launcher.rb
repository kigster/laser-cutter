# frozen_string_literal: true

module Laser
  module Cutter
    # Starts the CLI. The executable and the Aruba suite both build one, each
    # with its own argv and streams, and it exits only through kernel.exit.
    class Launcher
      def initialize(argv, stdin = $stdin, stdout = $stdout, stderr = $stderr, kernel = Kernel)
        @argv = argv
        @stdin = stdin
        @stdout = stdout
        @stderr = stderr
        @kernel = kernel
      end

      def execute!
        @kernel.exit(run)
      end

      private

      # dry-cli exits by itself after help or a usage error; its status is kept.
      def run
        Dry::CLI.new(CLI).call(arguments: @argv, out: @stdout, err: @stderr)
        0
      rescue SystemExit => e
        e.status
      rescue StandardError => e
        ui.error(e.message)
        @stderr.puts(e.backtrace) if @argv.intersect?(%w[-v --verbose])
        1
      end

      # The same boxes the commands draw, on this run's own streams.
      def ui
        CLI.console(out: @stdout, err: @stderr)
      end
    end
  end
end
