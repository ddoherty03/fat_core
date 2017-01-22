  class Symbol
    # Convert to capitalized string: :hello_world -> "Hello World"
    def entitle
      to_s.tr('_', ' ').split(' ').join(' ').entitle
    end
    alias to_string entitle

    def as_sym
      self
    end

    def tex_quote
      to_s.tex_quote
    end
  end
