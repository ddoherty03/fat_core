  class Symbol
    # Convert to capitalized string: :hello_world -> "Hello World"
    def entitle
      to_s.sub('_', ' ').split(' ')
        .join(' ')
        .entitle
    end
    alias :to_string :entitle

    def as_sym
      self
    end
  end
