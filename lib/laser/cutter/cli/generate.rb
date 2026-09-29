# frozen_string_literal: true

module Laser
  module Cutter
    module CLI
      class Generate < Command
        desc 'Draw the panels of a box into a PDF or an SVG file'

        # Options that describe the run rather than the box, kept out of a saved configuration.
        RUN_ONLY = %i[verbose read write open format args].freeze

        option :box, aliases: ['-b'], desc: 'WxHxD/T[/N]: width, height, depth, thickness and optional notch, in one'
        option :width, aliases: ['-w'], desc: 'Internal width of the box'
        option :height, aliases: ['-H'], desc: 'Internal height of the box'
        option :depth, aliases: ['-d'], desc: 'Internal depth of the box'
        option :thickness, aliases: ['-t'], desc: 'Thickness of the material'
        option :notch, aliases: ['-n'], desc: 'Notch length, a guide only (default: three times the thickness)'
        option :kerf, aliases: ['-k'], desc: 'Kerf, the width of the cut (default: 0.0024in)'
        option :units, default: 'in', values: %w[in mm], aliases: ['-u'], desc: 'Units every dimension is in'

        option :file, aliases: ['-o'], desc: 'File to write (required)'
        option :format, default: 'pdf', aliases: ['-f'], desc: 'Output format: pdf or svg, in either case'

        option :margin, aliases: ['-m'], desc: 'Margin from the edge of the page'
        option :padding, aliases: ['-p'], desc: 'Space between the panels'
        option :stroke, aliases: ['-s'], desc: 'Stroke width of the lines'
        option :page_size, aliases: ['-i'], desc: 'Page size, such as LETTER or A3 (default: fit the box; PDF only)'
        option :page_layout, default: 'portrait', values: %w[portrait landscape], aliases: ['-l'], desc: 'Page layout (PDF only)'

        option :metadata, type: :boolean, default: true, aliases: ['-M'], desc: 'Print the settings of the box on the page'
        option :inside_box, type: :boolean, default: false, aliases: ['-B'],
                            desc: 'Also draw the box without kerf, in red, to check the kerf'
        option :open, type: :boolean, default: false, aliases: ['-O'], desc: 'Open the file once it is written'
        option :write, aliases: ['-W'], desc: "Save the configuration to a file, or to STDOUT with '-'"
        option :read, aliases: ['-R'], desc: "Read the configuration from a file, or from STDIN with '-'"

        example [
          '-b 3x2x2/0.125 -o box.pdf # a box in inches',
          '-b 3x2x2/0.125 -f svg -o box.svg # as an SVG',
          '-u mm -w 70 -H 20 -d 50 -t 4.3 -o box.pdf'
        ]

        def call(format:, verbose:, **options)
          config = configuration(options)
          log_configuration(config) if verbose
          config.validate!
          ConfigFile.new(options[:write]).write(config.to_hash, out) if options[:write]

          renderer = Renderer.for(format, config)
          progress("Drawing #{config.file}", total: renderer.total) do |bar|
            renderer.render { bar.advance }
          end

          ui.success "Wrote #{config.file}: a #{config.width} x #{config.height} x #{config.depth} #{config.units} box."
          system('open', config.file) if options[:open]
        end

        private

        # What was read from a file, overridden by what the command line gave.
        def configuration(options)
          given = options.except(*RUN_ONLY).compact
          saved = options[:read] ? ConfigFile.new(options[:read]).read : {}
          settings = saved.transform_keys(&:to_sym).merge(given)
          Configuration.new(settings.merge(debug: settings.delete(:inside_box)))
        end

        def log_configuration(config)
          err.puts 'Starting with the following configuration:'
          err.puts JSON.pretty_generate(config.to_hash)
        end
      end
    end
  end
end
