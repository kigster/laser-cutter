require 'optparse'
require 'hashie/mash'
require 'laser_cutter/cli/banner'
require 'laser_cutter/config'
require 'forwardable'
module LaserCutter
  module CLI
    class Parser
      extend Forwardable

      def_delegators :@option_parser, :to_s

      attr_reader :options
      attr_writer :option_parser

      def initialize(options = Hashie::Mash.new)
        @options = options
      end

      def parse(*args)
        option_parser.parse!(args)
        options
      rescue OptionParser::InvalidOption,
        OptionParser::MissingArgument => e
        raise LaserCutter::Errors::CommandLineArgumentsError.new(e)
      end

      private

      def save
        ->(field) { ->(value) { @options[field] = value } }
      end

      def option_parser
        options = self.options
        @option_parser ||= OptionParser.new do |opts|
          opts.banner = BANNER
          opts.separator 'Dimensions:'.bold.blue
          opts.on('-w', '--width WIDTH', 'Internal width of the box', &save[:width])
          opts.on('-h', '--height HEIGHT', 'Internal height of the box', &save[:height])
          opts.on('-d', '--depth DEPTH', 'Internal depth of the box', &save[:depth])
          opts.on('-t', '--thickness THICKNESS', 'Thickness of the box material', &save[:thickness])
          opts.on('-n', '--notch NOTCH', 'Optional notch length (aka \'tab width\'), guide only', &save[:notch])
          opts.on('-k', '--kerf KERF', 'Cut width, amount of material removed by the cutter',
                  'The default is 0.051mm or 0.0035in.', &save[:kerf])
          opts.separator ''
          opts.separator 'Rendering:'.bold.blue
          opts.on('-m', '--margin MARGIN', 'Margins from the edge of the document', &save[:margin])
          opts.on('-p', '--padding PADDING', 'Space between the boxes on the page', &save[:padding])
          opts.on('-r', '--stroke WIDTH', 'Numeric stroke width of the line', &save[:stroke])
          opts.on('-M', '--metadata', 'Include info box with dimension in the PDF', &save[:print_metadata])
          opts.separator ''
          opts.separator 'Configuration:'.bold.blue
          opts.on('-W', '--write CONFIG_FILE', 'Save configuration to a file, or \'-\' for STDOUT', &save[:write_file])
          opts.on('-R', '--read CONFIG_FILE', 'Read configuration from a file, or \'-\' for STDIN', &save[:read_file])
          opts.separator ''
          opts.separator 'Debugging Flags:'.bold.blue
          opts.on('-v', '--verbose', 'Run verbosely', &save[:verbose])
          opts.on('-B', '--box', 'Draw the inner boxes (helpful to verify kerfing)', &save[:inner_box])
          opts.on('-D', '--debug', 'Show full exception stack trace on error', &save[:debug])
          opts.separator ''
          opts.separator 'Usage and Help:'.bold.blue
          opts.on('-e', '--examples', 'Show detailed usage examples') { options[:examples] = EXAMPLES }
          opts.on('-h', '--help', 'Show this message') { options[:help] = self.to_s }
          opts.on('-V', '--version', 'Show version') { options[:version] = LaserCutter::VERSION }
          opts.separator ''
          opts.separator 'Common Options:'.bold.blue
          opts.on_tail('-P', '--preview', 'Open generated file with a System Viewer before exiting', &save[:open])
          if `which open` == %q{/usr/bin/open}
            opts.on_tail('-F', '--finder', 'Open enclosing folder file with Finder', &save[:finder])
          end
          opts.on_tail('-s', '--size SIZE',
                       'Shortcut definition that combines all five dimensions:',
                       "using the format #{'W,H,D[,T[,N]]'.yellow} where W = width,",
                       'H = height, D = depth, T is thickness (optional), N is a tab width', ' ', &save[:combined])
          opts.on_tail('-o', '--file FILE', 'Save PDF to the file (required)', &save[:file])
          opts.on_tail('-u', '--units UNITS', "Convert to 'mm' from: #{LaserCutter::Config.supported_units}", &save[:units])
        end
      end
    end
  end
end
