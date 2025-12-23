# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/deep_dup'

# Gem Overview (extracted from README.org by gem_docs)
#
#
# * Introduction
#
# ~fat-core~ is somewhat of a grab bag of core class extensions that I have
# found useful across several projects.  It's higgeldy-piggeldy nature reflects
# the fact that none of them are important enough to deserve a gem of their own,
# but nonetheless need to be collected in one place to reduce redundancy across
# projects and provide a focused place to develop and test them.
module FatCore
  require 'fat_core/version'
  require 'fat_core/patches'
end
