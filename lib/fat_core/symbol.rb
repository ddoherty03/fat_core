  class Symbol
    # Convert to capitalized string: :hello_world -> "Hello World"
    def as_string
      to_s.sub('_', ' ').split(' ').map {|w| w.capitalize}.join(' ')
    end

    def as_sym
      self
    end
  end
