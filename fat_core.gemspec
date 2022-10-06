# coding: utf-8

require_relative 'lib/fat_core/version'

Gem::Specification.new do |spec|
  spec.name          = 'fat_core'
  spec.version       = FatCore::VERSION
  spec.authors       = ['Daniel E. Doherty']
  spec.email         = ['ded@ddoherty.net']
  spec.summary       = 'some useful core extensions'
  spec.description   = <<~DESC
     Useful extensions to Date, String, Range and other classes
     including useful Date extensions for dealing with US Federal
     and New York Stock Exchange holidays and working days, a useful
     Enumerable#each_with_flags for flagging first and last items in the
     iteration, (also for Hash), set operations on Ranges
  DESC
  spec.homepage      = 'https://github.com/ddoherty03/fat_core.git'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.2.2'
  spec.metadata['yard.run'] = 'yri' # use "yard" to build full HTML docs.

  spec.files         = `git ls-files -z`.split("\x0")
  spec.files.reject! { |fn| fn =~ /^NYSE_closings.pdf/ }
  spec.executables   = spec.files.grep(%r{^bin/easter}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'debug', '>= 1.0.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'solargraph'

  spec.add_runtime_dependency 'activesupport', '~>6.0'
  spec.add_runtime_dependency 'damerau-levenshtein'
end
