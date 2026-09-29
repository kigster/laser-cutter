# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      class Version < Command
        desc 'Print the version'

        def call(**)
          out.puts Laser::Cutter::VERSION
        end
      end
    end
  end
end
