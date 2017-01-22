require 'bundler/gem_tasks'

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec, :tag) do |t|
  t.rspec_opts = '--tag ~online -f p'
end

task :default => :spec
