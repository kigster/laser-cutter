require 'optparse'
require 'colored'
require 'json'
require 'hashie/mash'
require 'laser-cutter'
require_relative 'serializer'

module Laser
  module Cutter
    module CLI
      class OptParser
        def self.puts_error(e)
          STDERR.puts "Whoops, #{e}".red
          STDERR.puts "Try --help or --examples for more info...".yellow
        end

        def self.parse(args)
          banner_text = <<-EOF
#{('Laser-Cutter v'+ Laser::Cutter::VERSION).bold}

Usage: laser-cutter [options] -o filename.pdf
   eg: laser-cutter -z 1x1.5x2/0.125 -O -o box.pdf
          EOF

          examples = <<-EOF

Examples:
  1. Create a box defined in inches, and open PDF in preview right after:

       laser-cutter -z 3x2x2/0.125 -O -o box.pdf

  2. Create a box defined in millimeters, print verbose info, and set
     page size to A3, and layout to landscape, and stroke width to 1/2mm:

       laser-cutter -u mm -w70 -h20 -d50 -t4.3 -n5 -iA3 -l landscape -k0.5 -v -O -o box.pdf

  3. List all possible page sizes in metric systems:

       laser-cutter -L -u mm

  4. Create a box with provided dimensions, and save the config to a file
     for later use:

       laser-cutter -z 1.1x2.5x1.5/0.125/0.125 -p 0.1 -O -o box.pdf -W box-settings.json

  5. Read settings from a previously saved file:

       laser-cutter -O -o box.pdf -R box-settings.json
       cat box-settings.json | laser-cutter -O -o box.pdf -R -

          EOF
          options = Hashie::Mash.new
          options.verbose = false
          options.units = 'in'

          opt_parser = OptionParser.new do |opts|
            opts.banner = banner_text.blue
            opts.separator "Specific Options:"
            opts.on("-w", "--width WIDTH", "Internal width of the box") { |value| options.width = value }
            opts.on("-h", "--height HEIGHT", "Internal height of the box") { |value| options.height = value }
            opts.on("-d", "--depth DEPTH", "Internal depth of the box") { |value| options.depth= value }
            opts.on("-t", "--thickness THICKNESS", "Thickness of the box material") { |value| options.thickness = value }
            opts.on("-n", "--notch NOTCH", "Optional notch length (aka \"tab width\"), guide only") { |value| options.notch = value }
            opts.on("-k", "--kerf KERF", "Optional kerf (cut) width (default depends on material thickness)") { |value| options.kerf = value }
            opts.separator ""
            opts.on("-m", "--margin MARGIN", "Margins from the edge of the document") { |value| options.margin = value }
            opts.on("-p", "--padding PADDING", "Space between the boxes on the page") { |value| options.padding = value }
            opts.on("-s", "--stroke WIDTH", "Numeric stroke width of the line") { |value| options.stroke = value }
            opts.on("-i", "--page_size LETTER", "Document page size, default is autofit the box.") { |value| options.page_size = value }
            opts.on("-l", "--page_layout portrait", "Page layout, other option is 'landscape' ") { |value| options.page_layout = value }
            opts.separator ""
            opts.on("-O", "--open", "Open generated file with system viewer before exiting") { |v| options.open = v }
            opts.on("-W", "--write CONFIG_FILE", "Save provided configuration to a file, use '-' for STDOUT") { |v| options.write_file = v }
            opts.on("-R", "--read CONFIG_FILE", "Read configuration from a file, or use '-' for STDIN") { |v| options.read_file = v }
            opts.separator ""
            opts.on("-L", "--list-all-page-sizes", "Print all available page sizes with dimensions and exit") { |v| options.list_all_page_sizes = true }
            opts.on("-M", "--no-metadata", "Do not print box metadata on the PDF") { |value| options.metadata = value }
            opts.on("-v", "--[no-]verbose", "Run verbosely") { |v| options.verbose = v }
            opts.on("-B", "--inside-box", "Draw the inside boxes (helpful to verify kerfing)") { |v| options.inside_box = v }
            opts.on("-D", "--debug", "Show full exception stack trace on error") { |v| options.debug = v }
            opts.separator ""
            opts.on("--examples", "Show detailed usage examples") { puts opts; puts examples.yellow; exit }
            opts.on("--help", "Show this message") { puts opts; exit }
            opts.on("--version", "Show version") { puts Laser::Cutter::VERSION; exit }
            opts.separator ""
            opts.separator "Common Options:"
            opts.on_tail("-o", "--file FILE", "Required output filename of the PDF") { |value| options.file = value }
            opts.on_tail("-z", "--size WxHxD/T[/N]",
                         "Combined internal dimensions: W = width, H = height,\n#{" " * 37}D = depth, T = thickness, and optional N = notch length\n\n") do |size|
              options.size = size
            end
            opts.on_tail("-u", "--units UNITS", "Either 'in' for inches (default) or 'mm'") { |value| options.units = value }
          end

          opt_parser.parse!(args)

          if options.read_file
            # these options are kept from the command line
            override_with = %w(debug verbose read_file)
            keep = options.reject{ |k,v| !override_with.include?(k)}
            Serializer.new(options).deserialize
            options.merge!(keep)
          end

          config = Laser::Cutter::Configuration.new(options.to_hash)
          if config.list_all_page_sizes
            puts PageManager.new(config.units).all_page_sizes
            exit 0
          end

          if options.verbose
            puts "Starting with the following configuration:"
            puts JSON.pretty_generate(config.to_hash).green
          end

          config.validate!

          if config.write_file
            Serializer.new(config).serialize
          end

          config
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument, Laser::Cutter::MissingOption => e
          puts opt_parser.banner.blue
          puts_error(e)
          exit 1
        end
      end
    end
  end
end
