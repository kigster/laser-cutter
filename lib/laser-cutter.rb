require 'prawn'
require 'prawn/measurement_extensions'
require 'require_dir'
module Laser
  module Cutter
    extend RequireDir
    init_from_source __FILE__
  end
end

Laser::Cutter.dir_r('laser-cutter/geometry')
Laser::Cutter.dir('laser-cutter')
