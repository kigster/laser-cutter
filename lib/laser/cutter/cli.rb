# frozen_string_literal: true

module Laser
  module Cutter
    # Every command the executable answers to.
    module CLI
      extend Dry::CLI::Registry

      PROGRAM = 'laser-cutter'

      # Help is never wider than this, however wide the terminal is.
      HELP_WIDTH = 90

      # Columns assumed when there is no terminal, or it reports none.
      DEFAULT_COLUMNS = 80

      # @return [Integer] columns help wraps at: the terminal's less 6, capped at HELP_WIDTH
      def self.help_width(columns = IO.console&.winsize&.last)
        columns = DEFAULT_COLUMNS unless columns&.positive?
        [columns - 6, HELP_WIDTH].min
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
      register 'completion', Dry::CLI::Autocomplete::Command[self, program_name: PROGRAM]
    end
  end
end
