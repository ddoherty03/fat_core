require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/')
  rdoc.options << "--ri"
end

RSpec::Core::RakeTask.new(:spec, :tag) do |t|
  t.rspec_opts = '--tag ~online -f p'
end

task :default => :spec
