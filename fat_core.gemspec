# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fat_core/version'

Gem::Specification.new do |spec|
  spec.name          = 'fat_core'
  spec.version       = FatCore::VERSION
  spec.authors       = ['Daniel E. Doherty']
  spec.email         = ['ded@ddoherty.net']
  spec.summary       = 'fat_core provides some useful core extensions'
  spec.description   = 'Write a longer description. Optional.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.files.reject! { |fn| fn =~ /^NYSE_closings.pdf/ }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rcodetools'

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'erubis'
  spec.add_runtime_dependency 'damerau-levenshtein'
end
