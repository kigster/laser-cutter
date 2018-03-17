# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'laser-cutter/version'

Gem::Specification.new do |spec|
  spec.name          = "laser-cutter"
  spec.version       = Laser::Cutter::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = ["kigster@gmail.com"]
  spec.summary       = %q{Creates notched box outlines for laser-cut boxes which are geometrically symmetric and pleasing to the eye.}
  spec.description   = %q{Similar to the older BoxMaker, this ruby gem generates PDFs that can be used as a basis for cutting boxes on a typical laser cutter. The intention was to create an extensible, well tested, and modern ruby gem for generating PDF templates used in laser cutting.}
  spec.homepage      = "https://github.com/kigster/laser-cutter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'prawn'
  spec.add_dependency 'hashie'
  spec.add_dependency 'colored2'

  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
