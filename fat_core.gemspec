# coding: utf-8
# frozen_string_literal: true

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

  spec.files = %x[git ls-files -z].split("\x0")
  spec.files.reject! { |fn| fn =~ /^NYSE_closings.pdf/ }
  spec.executables   = spec.files.grep(%r{^bin/easter}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport'
  spec.add_dependency 'damerau-levenshtein'
  spec.add_dependency 'ostruct'
  spec.add_dependency 'stringio', '>=3.1.2'
end
