# frozen_string_literal: true

module Laser
  module Cutter
    # Every command the executable answers to.
    module CLI
      extend Dry::CLI::Registry

      PROGRAM = 'laser-cutter'

      # Help and boxes are never wider than this, however wide the terminal is.
      HELP_WIDTH = 90

      # Columns assumed when there is no terminal, or it reports none.
      DEFAULT_COLUMNS = 80

      # `COLUMNS` wins over the console, as it does for dry-cli-help, so a test can pin the width.
      #
      # @return [Integer] columns help wraps at, and a box takes: the terminal's less 6,
      #   capped at HELP_WIDTH
      def self.help_width(columns = Dry::CLI::Help::Terminal.width)
        columns = DEFAULT_COLUMNS unless columns&.positive?
        [columns - 6, HELP_WIDTH].min
      end

      # Boxes as wide as help. dry-cli-ui assumes 80 columns on a stream that is
      # not a tty, such as a pipe, so it is told the terminal's width.
      #
      # @return [Dry::CLI::UI::Console]
      def self.console(out:, err:)
        Dry::CLI::UI::Console.new(out: out, err: err, width: Dry::CLI::Help::Terminal.width, box_width: help_width)
      end

      Dry::CLI::Help.configure do
        title "laser-cutter #{Laser::Cutter::VERSION}"
        description 'Draws the notched panels of a box, ready to cut on a laser cutter, as a PDF or an SVG.'
        epilogue 'Documentation: https://github.com/kigster/laser-cutter'

        width CLI.help_width
        exit_code_without_arguments 0

        styles do
          heading :bold, :cyan, case: :UPPERCASE
          usage :yellow
          example :yellow
          option :green
          example_comment :bright_black
        end
      end

      register 'generate', Generate, aliases: ['g']
      register 'page-sizes', PageSizes
      register 'examples', Examples
      register 'help', Help
      register 'version', Version, aliases: ['-V', '--version']
      register 'completion', Completion
    end
  end
end
