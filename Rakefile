require "bundler/gem_tasks"
require 'cucumber/rake/task'

Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format progress}
end

task :default => :cucumber
