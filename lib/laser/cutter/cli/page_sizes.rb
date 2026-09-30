# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      class PageSizes < Command
        desc 'List every page size, with its dimensions'

        option :units, default: 'in', values: %w[in mm], aliases: ['-u'], desc: 'Units to print the dimensions in'

        example ['', '--units mm']

        def call(units:, **)
          out.puts PageManager.new(units).all_page_sizes
        end
      end
    end
  end
end
