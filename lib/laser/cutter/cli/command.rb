# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      # What every command inherits: the ui helpers, and the flags they all share.
      class Command < Dry::CLI::Command
        include Dry::CLI::UI

        # Columns a box or a progress bar takes.
        WIDGET_WIDTH = 60

        def self.inherited(subclass)
          super
          subclass.option :verbose, type: :boolean, default: false, aliases: ['-v'],
                                    desc: 'Print the configuration, and the full backtrace on failure'
        end

        # Boxes are WIDGET_WIDTH columns wide.
        def ui
          @ui ||= Dry::CLI::UI::Console.new(out: out, err: err, box_width: WIDGET_WIDTH)
        end

        # A green bar of WIDGET_WIDTH cells, or fewer when the terminal is narrower.
        #
        # @param label [String]
        # @param total [Integer]
        # @yieldparam bar [#advance]
        def progress(label, total:, &)
          Dry::CLI::UI::Console
            .new(out: out, err: err, box_width: WIDGET_WIDTH, width: progress_width(label))
            .progress(label, total: total, color: :green, &)
        end

        private

        # dry-cli-ui sizes a bar as the terminal width less the label and the
        # counters around it, so the bar is capped by capping that width.
        def progress_width(label)
          wanted = WIDGET_WIDTH + label.length + Dry::CLI::UI::Widgets::Progress::CHROME
          err.respond_to?(:tty?) && err.tty? ? [wanted, TTY::Screen.width].min : wanted
        end
      end
    end
  end
end
