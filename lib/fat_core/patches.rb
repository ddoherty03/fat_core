# Provide #positive? and #negative? for older versions of Ruby.
unless 2.respond_to?(:positive?)
  class Numeric
    def positive?
      self > 0
    end
  end
end

unless 2.respond_to?(:negative?)
  class Numeric
    def negative?
      self < 0
    end
  end
end
