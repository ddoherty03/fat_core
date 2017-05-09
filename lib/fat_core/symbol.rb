require 'fat_core/string'

module FatCore
  module Symbol
    # Convert to capitalized string: :hello_world -> "Hello World"
    def entitle
      to_s.tr('_', ' ').split(' ').join(' ').entitle
    end
    alias as_string entitle

    def as_sym
      self
    end

    def tex_quote
      to_s.tex_quote
    end
  end
end

Symbol.include(FatCore::Symbol)
