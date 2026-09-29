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
require "zeitwerk"

module Laser
  module Cutter
    class Error < StandardError; end
  end
end

loader = Zeitwerk::Loader.for_gem_extension(Laser)
loader.inflector.inflect("cli" => "CLI")
loader.setup
loader.eager_load
