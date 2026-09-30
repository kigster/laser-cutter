# frozen_string_literal: true

require "forwardable"
require "json"
require "matrix"

require "hashie/mash"
require "hashie/extensions/symbolize_keys"
require "hashie/extensions/mash/symbolize_keys"
require "pdf/core/page_geometry"
require "prawn"
require "prawn/measurement_extensions"
require "dry/cli"
require "dry/cli/help"
require "dry/cli/ui"
require "dry/cli/autocomplete/command"
require "dry/struct"
require "tty-screen"
require "zeitwerk"

module Laser
  # Draws the notched panels of a box. A Ruby program needs {Options},
  # {Cutter.render} and {Cutter.write}; the command line is one caller of many.
  module Cutter
    class Error < StandardError; end

    class << self
      # Draws a box, and returns the document without writing a file.
      #
      # @example In a Rails controller
      #   box = params.require(:box).permit(*Laser::Cutter::Options.attribute_names)
      #   options = Laser::Cutter::Options.new(box.to_h)
      #   send_data Laser::Cutter.render(options), type: "application/pdf", filename: "box.pdf"
      #
      # @param options [Options, Hash] a Hash becomes an {Options}
      # @yieldparam line [Geometry::Line] each line, once it is drawn
      # @return [String] the PDF, or the SVG when the options ask for one
      # @raise [MissingOption, InvalidOption]
      def render(options, &)
        options = Options.new(options)
        Renderer.for(options.format || Renderer::FORMATS.keys.first, options.to_configuration).document(&)
      end

      # Draws a box into the file the options name. Without a format, the
      # extension of the file decides, and anything but .svg is a PDF.
      #
      # @param options [Options, Hash] a Hash becomes an {Options}
      # @yieldparam line [Geometry::Line] each line, once it is drawn
      # @return [String] the path of the file
      # @raise [MissingOption, InvalidOption]
      def write(options, &)
        options = Options.new(options)
        raise MissingOption, 'file is required, but missing.' unless options.file

        extension = File.extname(options.file).delete('.').downcase
        format = options.format || (Renderer::FORMATS.key?(extension) ? extension : nil)
        File.binwrite(options.file, render(options.new(format: format), &))
        options.file
      end
    end
  end
end

loader = Zeitwerk::Loader.for_gem_extension(Laser)
loader.inflector.inflect("cli" => "CLI")
loader.setup
loader.eager_load
