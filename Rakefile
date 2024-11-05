require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'
require 'yard'

RDoc::Task.new do |rdoc|
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'lib/')
  rdoc.options << "--ri"
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'README.md']
  t.options << '--no-private'
  t.options << '--embed-mixins'
  t.options << '--markup=markdown'
  t.options << '--markup-provider=redcarpet'
  # t.stats_options = ['--list-undoc']
end

RSpec::Core::RakeTask.new(:spec, :tag) do |t|
  t.rspec_opts = '--tag ~online -f p'
end

########################################################################
# Rubocop tasks
########################################################################
require 'rubocop/rake_task'

RuboCop::RakeTask.new

task :default => [:spec, :rubocop]
