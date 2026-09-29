# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "timeout"
require "yard"

def shell(*args)
  puts "running: #{args.join(' ')}"
  system(args.join(" "))
end

task :clean do
  shell("rm -rf pkg/ tmp/ coverage/ doc/ ")
end

task gem: [:build] do
  shell("gem install pkg/*")
end

task permissions: [:clean] do
  # One traversal replaces a six-level glob chain that printed "No such file
  # or directory" for every level this project does not have, skipped dotfiles
  # entirely, and silently stopped at depth six. .git is pruned: its objects
  # have no business being group-readable.
  shell("find . -path ./.git -prune -o -type d -exec chmod o+rx,g+rx {} + -o -type f -exec chmod o+r,g+r {} +")
end

task build: :permissions

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w[lib/**/*.rb - README.md LICENSE.txt CHANGELOG.md]
  t.options.unshift("--title", '"dry-cli-ui: runtime terminal UI for dry-cli commands"')
  t.after = -> { exec("open doc/index.html") } if RUBY_PLATFORM =~ /darwin/
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
