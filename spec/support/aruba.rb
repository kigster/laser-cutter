# frozen_string_literal: true

require "aruba/rspec"

# In-process: the suite builds a Launcher per example instead of forking, so
# the CLI's own code counts towards coverage.
Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class = Laser::Cutter::Launcher
end
