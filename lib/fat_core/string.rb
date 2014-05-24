class String
  # See if self contains colon- or space-separated words that include
  # the colon- or space-separated words of other.  Return the matched
  # portion of self.  Other cannot be a regex embedded in a string.
  def fuzzy_match(other)
    # Remove periods, commas, and apostrophes
    other = other.gsub(/[.,']/, '')
    target = self.gsub(/[.,']/, '')
    matched_text = nil
    matchers = other.split(/[: ]+/)
    regexp_string = matchers.map {|m| ".*?#{Regexp.escape(m)}.*?"}.join('[: ]')
    regexp_string.sub!(/^\.\*\?/, '')
    regexp_string.sub!(/\.\*\?$/, '')
    regexp = /#{regexp_string}/i
    if match = regexp.match(target)
      matched_text = match[0]
    else
      matched_text = nil
    end
    matched_text
  end

  # Here are instance methods for the class that includes Matchable
  # This tries to convert the receiver object into a string, then
  # matches against the given matcher, either via regex or a fuzzy
  # string matcher.
  def matches_with(str)
    if str.nil?
      nil
    elsif str =~ /^\s*\//
      re = str.to_regexp
      if self.to_s =~ re
        $&
      else
        nil
      end
    else
      self.to_s.fuzzy_match(str)
    end
  end

  # Convert a string of the form '/.../Iixm' to a regular expression. However,
  # make the regular expression case-insensitive by default and extend the
  # modifier syntax to allow '/I' to indicate case-sensitive.
  def to_regexp
    if self =~ /^\s*\/([^\/]*)\/([Iixm]*)\s*$/
      body = $1
      opts = $2
      flags = Regexp::IGNORECASE
      unless opts.blank?
        flags = 0 if opts.include?('I')
        flags |= Regexp::IGNORECASE if opts.include?('i')
        flags |= Regexp::EXTENDED if opts.include?('x')
        flags |= Regexp::MULTILINE if opts.include?('m')
      end
      flags = nil if flags == 0
      Regexp.new(body, flags)
    else
      Regexp.new(self)
    end
  end

  # Convert to symbol "Hello World" -> :hello_world
  def as_sym
    strip.squeeze(' ').gsub(/\s+/, '_').downcase.to_sym
  end

  def as_string
    self
  end

  def wrap(width=70, hang=0)
    offset = 0
    trip = 1
    result = ''
    while (s = slice(offset, width))
      offset += width
      if trip == 1
        width -= hang
      else
        s = (' ' * hang) + s
      end
      result << s + "\n"
      trip += 1
    end
    # Remove the final newline before exiting
    result.strip
  end

  def tex_quote
    r = self.dup
    r = r.gsub(/[{]/, 'XzXzXobXzXzX')
    r = r.gsub(/[}]/, 'XzXzXcbXzXzX')
    r = r.gsub(/\\/, '\textbackslash{}')
    r = r.gsub(/\^/, '\textasciicircum{}')
    r = r.gsub(/~/, '\textasciitilde{}')
    r = r.gsub(/\|/, '\textbar{}')
    r = r.gsub(/\</, '\textless{}')
    r = r.gsub(/\>/, '\textgreater{}')
    r = r.gsub(/([_$&%#])/) { |m| '\\' + m }
    r = r.gsub('XzXzXobXzXzX', '\\{')
    r = r.gsub('XzXzXcbXzXzX', '\\}')
  end

  def self.random(size = 8)
    "abcdefghijklmnopqrstuvwxyz".split('').shuffle[0..size].join('')
  end

  # Convert a string with an all-digit date to an iso string
  # E.g., "20090923" -> "2009-09-23"
  def digdate2iso
    self.sub(/(\d\d\d\d)(\d\d)(\d\d)/, '\1-\2-\3')
  end

  def entitle!
    little_words = %w[ a an the and or in on under of from as by to ]
    newwords = []
    words = split(/\s+/)
    first_word = true
    num_words = words.length
    words.each_with_index do |w, k|
      last_word = (k + 1 == num_words)
      if w =~ %r[c/o]i
        # Care of
        newwords.push("c/o")
      elsif w =~ %r[^p\.?o\.?$]i
        # Post office
        newwords.push("P.O.")
      elsif w =~ %r[^[0-9]+(st|nd|rd|th)$]i
        # Ordinals
        newwords.push(w.downcase)
      elsif w =~ %r[^[^aeiouy]*$]i
        # All consonants, probably abbr
        newwords.push(w.upcase)
      elsif w =~ %r[^(us|ne|se|rr)$]i
        # Common 2-letter abbrs with vowels
        newwords.push(w.upcase)
      elsif w =~ %r[^[0-9].*$]i
        # Other runs starting with numbers,
        # like 3-A
        newwords.push(w.upcase)
      elsif w =~ %r[^(\w+)-(\w+)$]i
        # Hypenated double word
        newwords.push($1.capitalize + '-' + $2.capitalize)
      elsif little_words.include?(w.downcase)
        # Only capitalize at beginning or end
        newwords.push((first_word or last_word) ? w.capitalize : w.downcase)
      else
        # All else
        newwords.push(w.capitalize)
      end
      first_word = false
    end
    self[0..-1] = newwords.join(' ')
  end

  def entitle
    self.dup.entitle!
  end

  # Thanks to Eugene at stackoverflow for the following.
  # http://stackoverflow.com/questions/8806643/
  #   colorized-output-breaks-linewrapping-with-readline
  # These color strings without confusing readline about the length of
  # the prompt string in the shell. (Unlike the rainbow routines)
  def console_red;          colorize(self, "\001\e[1m\e[31m\002");  end
  def console_dark_red;     colorize(self, "\001\e[31m\002");       end
  def console_green;        colorize(self, "\001\e[1m\e[32m\002");  end
  def console_dark_green;   colorize(self, "\001\e[32m\002");       end
  def console_yellow;       colorize(self, "\001\e[1m\e[33m\002");  end
  def console_dark_yellow;  colorize(self, "\001\e[33m\002");       end
  def console_blue;         colorize(self, "\001\e[1m\e[34m\002");  end
  def console_dark_blue;    colorize(self, "\001\e[34m\002");       end
  def console_purple;       colorize(self, "\001\e[1m\e[35m\002");  end

  def console_def;          colorize(self, "\001\e[1m\002");  end
  def console_bold;         colorize(self, "\001\e[1m\002");  end
  def console_blink;        colorize(self, "\001\e[5m\002");  end

  def colorize(text, color_code)  "#{color_code}#{text}\001\e[0m\002" end
end
