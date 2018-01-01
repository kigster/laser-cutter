require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

def shell(*args)
  puts "running: #{args.join(' ')}"
  system(args.join(' '))
end

task :clean do
  shell('rm -rf pkg/ tmp/ coverage/' )
end

task :permissions => [ :clean ] do
  shell("chmod -v o+r,g+r * */* */*/* */*/*/* */*/*/*/* */*/*/*/*/*")
  shell("find . -type d -exec chmod o+x,g+x {} \\;")
end

task :build => :permissions

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w(lib/**/*.rb bin/* - README.md LICENSE.txt BOXMAKER.md)
  t.options.unshift('--title','LaserCutter Library')
  t.after = ->() { exec('open doc/index.html') }
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
