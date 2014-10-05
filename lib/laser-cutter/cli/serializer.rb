require 'json'
require 'laser-cutter'

module Laser
  module Cutter
    module CLI
      class Serializer
        attr_accessor :options
        def initialize(options = {})
          self.options = options
        end

        def deserialize
          string = if options.read_file.eql?('-')
                     $stdin.read
                   elsif File.exist?(options.read_file)
                     File.read(options.read_file)
                   end
          if string
            options.replace(JSON.load(string))
          end
        rescue Exception => e
          STDERR.puts "Error reading options from file #{options.read_file}, #{e.message}".red
          if options.verbose
            STDERR.puts e.backtrace.join("\n").red
          end
          exit 1
        end

        def serialize
          output = if options.write_file.eql?('-')
                     $stdout
                   elsif options.write_file
                     File.open(options.write_file, 'w')
                   else
                     nil
                   end
          output.puts(JSON.pretty_generate(options))
          output.close if output != $stdout
        rescue Exception => e
          STDERR.puts "Error writing options to file #{options.write_file}, #{e.message}".red
          if options.verbose
            STDERR.puts e.backtrace.join("\n").red
          end
          exit 1
        end
      end
    end
  end
end

