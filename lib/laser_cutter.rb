require 'prawn'
require 'prawn/measurement_extensions'

module LaserCutter
  class << self
    def require_dir(folder)
      ::Dir.glob(
        File.dirname(
          File.absolute_path(__FILE__)) + '/' + folder + '/*.rb') do |file|
        short_name = file.gsub(/.*lib\//, '').gsub(/\.rb$/, '')
        Kernel.require(short_name)
      end
    end
  end
end

LaserCutter.require_dir 'laser_cutter/cli'
LaserCutter.require_dir 'laser_cutter'
