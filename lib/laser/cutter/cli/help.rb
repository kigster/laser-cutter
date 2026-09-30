# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      class Help < Command
        desc 'Show help, for the program or for one command'

        argument :command, required: false, desc: 'The command to explain'

        example ['', 'generate']

        # Asks dry-cli for the help it prints on --help, which exits by itself.
        def call(command: nil, **)
          Dry::CLI.new(CLI).call(arguments: [command, '--help'].compact, out: out, err: err)
        end
      end
    end
  end
end
