# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      # Dry::CLI::Autocomplete::Command[] builds an anonymous subclass, which
      # loses the description and the examples. This one states its own.
      class Completion < Dry::CLI::Autocomplete::Command
        @registry = CLI
        @program_name = PROGRAM

        desc 'Generates auto-complete for BASH or ZSH'

        example [
          "bash > /usr/local/etc/bash_completion.d/#{PROGRAM}",
          "zsh  > \"${fpath[1]}/_#{PROGRAM}\""
        ]
      end
    end
  end
end
