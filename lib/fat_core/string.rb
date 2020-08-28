# frozen_string_literal: true

require 'bigdecimal'
require 'fat_core/patches'
require 'damerau-levenshtein'
require 'active_support/core_ext/regexp'

module FatCore
  module String
    # @group Transforming
    # :section: Transforming

    # Remove leading and trailing white space and compress internal runs of
    # white space to a single space.
    #
    # @example
    #   '  hello   world\n  '.clean #=> 'hello world'
    #
    # @return [String]
    def clean
      strip.squeeze(' ')
    end

    # Convert to a lower-case symbol with all white space converted to a single
    # '_' and all non-alphanumerics deleted, such that the string will work as
    # an unquoted Symbol.
    #
    # @example
    #   "Hello World" -> :hello_world
    #   "Hello*+World" -> :helloworld
    #
    # @return [Symbol] self converted to a Symbol
    def as_sym
      clean
        .gsub(/\s+/, '_')
        .gsub(/[^_A-Za-z0-9]/, '')
        .downcase.to_sym
    end

    # Return self unmodified. This method is here so to comply with the API of
    # Symbol#as_string so that it can be applied to a variable that is either a
    # String or a Symbol.
    #
    # @return [String] self unmodified
    def as_string
      self
    end

    # Return a string wrapped to `width` characters with lines following the
    # first indented by `hang` characters.
    #
    # @return [String] self wrapped
    def wrap(width = 70, hang = 0)
      result = ::String.new
      first_line = true
      first_word_on_line = true
      line_width_so_far = 0
      words = split(' ')
      words.each do |w|
        w = ::String.new(' ') * hang + w if !first_line && first_word_on_line
        w = ::String.new(' ') + w unless first_word_on_line
        result << w
        first_word_on_line = false
        line_width_so_far += 1 + w.length
        next unless line_width_so_far >= width

        result << "\n"
        line_width_so_far = 0
        first_line = false
        first_word_on_line = true
      end
      result.strip
    end

    # Return self with special TeX characters replaced with control-sequences
    # that output the literal value of the special characters instead.  It
    # handles _, $, &, %, #, {, }, \, ^, ~, <, and >.
    #
    # @example
    #   '$100 & 20#'.tex_quote #=> '\\$100 \\& 20\\#'
    #
    # @return [String] self quoted
    def tex_quote
      r = dup
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
      r.gsub('XzXzXcbXzXzX', '\\}')
    end

    # Convert a string representing a date with only digits, hyphens, or slashes
    # to a Date.
    #
    # @example
    #   "20090923".as_date.iso -> "2009-09-23"
    #   "2009/09/23".as_date.iso -> "2009-09-23"
    #   "2009-09-23".as_date.iso -> "2009-09-23"
    #   "2009-9-23".as_date.iso -> "2009-09-23"
    #
    # @return [Date] the translated Date
    def as_date
      if self =~ %r{(?<yr>\d\d\d\d)[-/]?(?<mo>\d\d?)[-/]?(?<dy>\d\d?)}
        ::Date.new(Regexp.last_match[:yr].to_i,
                   Regexp.last_match[:mo].to_i,
                   Regexp.last_match[:dy].to_i)
      end
    end

    UPPERS = ('A'..'Z').to_a

    private

    def upper?
      UPPERS.include?(self[0])
    end

    # Return true if all the letters in self are upper case
    def all_upper?
      tr('^A-Za-z', '').split('').all? { |c| ('A'..'Z').to_a.include? c }
    end

    public

    # Return self capitalized according to the conventions for capitalizing
    # titles of books or articles. Tries to follow the rules of the University
    # of Chicago's *A Manual of Style*, Section 7.123, except to the extent that
    # doing so requires knowing the parts of speech of words in the title. Also
    # tries to use sensible capitalization for things such as postal address
    # abbreviations, like P.O Box, Ave., Cir., etc. Considers all-consonant
    # words of 3 or more characters as acronyms to be kept all uppercase, e.g.,
    # ddt => DDT, and words that are all uppercase in the input are kept that
    # way, e.g. IBM stays IBM. Thus, if the source string is all uppercase, you
    # should lowercase the whole string before using #entitle, otherwise is will
    # not have the intended effect.
    #
    # @example 'now is the time for all good men' #=> 'Now Is the Time for All
    #   Good Men' 'how in the world does IBM do it?'.entitle #=> "How in the
    #   World Does IBM Do It?" 'how in the world does ibm do it?'.entitle #=>
    #   "How in the World Does Ibm Do It?" 'ne by nw'.entitle #=> 'NE by NW' 'my
    #   life: a narcissistic tale' => 'My Life: A Narcissistic Tale'
    #
    # @return [String]
    def entitle
      little_words = %w[a an the at for up and but
                        or nor in on under of from as by to]
      preserve_acronyms = !all_upper?
      newwords = []
      capitalize_next = false
      words = split(/\s+/)
      last_k = words.size - 1
      words.each_with_index do |w, k|
        first = k.zero?
        last = (k == last_k)
        if w =~ %r{c/o}i
          # Care of
          newwords.push('c/o')
        elsif w =~ /^p\.?o\.?$/i
          # Post office
          newwords.push('P.O.')
        elsif w =~ /^[0-9]+(st|nd|rd|th)$/i
          # Ordinals
          newwords.push(w.downcase)
        elsif w =~ /^(cr|dr|st|rd|ave|pk|cir)$/i
          # Common abbrs to capitalize
          newwords.push(w.capitalize)
        elsif w =~ /^(us|ne|se|rr)$/i
          # Common 2-letter abbrs to upcase
          newwords.push(w.upcase)
        elsif w =~ /^[0-9].*$/i
          # Other runs starting with numbers,
          # like 3-A
          newwords.push(w.upcase)
        elsif w =~ /^(N|S|E|W|NE|NW|SE|SW)$/i
          # Compass directions all caps
          newwords.push(w.upcase)
        elsif w =~ /^[^aeiouy]*$/i && w.size > 2
          # All consonants and at least 3 chars, probably abbr
          newwords.push(w.upcase)
        elsif w =~ /^[A-Z0-9]+\z/ && preserve_acronyms
          # All uppercase and numbers, keep as is
          newwords.push(w)
        elsif w =~ /^(\w+)-(\w+)$/i
          # Hyphenated double word
          newwords.push($1.capitalize + '-' + $2.capitalize)
        elsif capitalize_next
          # Last word ended with a ':'
          newwords.push(w.capitalize)
          capitalize_next = false
        elsif little_words.include?(w.downcase)
          # Only capitalize at beginning or end
          newwords.push(first || last ? w.capitalize : w.downcase)
        else
          # All else
          newwords.push(w.capitalize)
        end
        # Capitalize following a ':'
        capitalize_next = true if newwords.last =~ /:\s*\z/
      end
      newwords.join(' ')
    end

    # @group Matching
    # :section: Matching

    # Return the Damerau-Levenshtein distance between self an another string
    # using a transposition block size of 1 and quitting if a max distance of 10
    # is reached.
    #
    # @param other [#to_s] string to compute self's distance from
    # @return [Integer] the distance between self and other
    def distance(other)
      DamerauLevenshtein.distance(self, other.to_s, 1, 10)
    end

    # Test whether self matches the `matcher` treating `matcher` as a
    # case-insensitive regular expression if it is of the form '/.../' or as a
    # string to #fuzzy_match against otherwise.
    #
    # @param matcher [String] regexp if looks like /.../; #fuzzy_match pattern otherwise
    # @return [nil] if no match
    # @return [String] the matched portion of self, with punctuation stripped in
    #   case of #fuzzy_match
    # @see #fuzzy_match #fuzzy_match for the specifics of string matching
    # @see #as_regexp #as_regexp for conversion of `matcher` to regular expression
    def matches_with(matcher)
      if matcher.nil?
        nil
      elsif matcher =~ %r{^\s*/}
        re = matcher.as_regexp
        $& if to_s =~ re
      else
        to_s.fuzzy_match(matcher)
      end
    end

    # Return the matched portion of self, minus punctuation characters, if self
    # matches the string `matcher` using the following notion of matching:
    #
    # 1. Remove all periods, commas, apostrophes, and asterisks (the punctuation
    #    characters) from both self and `matcher`,
    # 2. Treat ':' in the matcher as the equivalent of '.*' in a regular
    #    expression, that is, match anything in self,
    # 3. Ignore case in the match
    # 4. Match if any part of self matches `matcher`
    #
    # @example
    #   "St. Luke's Hospital".fuzzy_match('st lukes') #=> 'St Lukes'
    #   "St. Luke's Hospital".fuzzy_match('luk:hosp') #=> 'Lukes Hosp'
    #   "St. Luke's Hospital".fuzzy_match('st:spital') #=> 'St Lukes Hospital'
    #   "St. Luke's Hospital".fuzzy_match('st:laks') #=> nil
    #
    # @param matcher [String] pattern to test against where ':' is wildcard
    # @return [String] the unpunctuated part of self that matched
    # @return [nil] if self did not match matcher
    def fuzzy_match(matcher)
      # Remove periods, asterisks, commas, and apostrophes
      matcher = matcher.gsub(/[\*.,']/, '')
      target = gsub(/[\*.,']/, '')
      matchers = matcher.split(/[: ]+/)
      regexp_string = matchers.map { |m| ".*?#{Regexp.escape(m)}.*?" }.join('[: ]')
      regexp_string.sub!(/^\.\*\?/, '')
      regexp_string.sub!(/\.\*\?$/, '')
      regexp = /#{regexp_string}/i
      matched_text =
        if (match = regexp.match(target))
          match[0]
        end
      matched_text
    end

    REGEXP_META_CHARACTERS = "\\$()*+.<>?[]^{|}".chars.freeze

    # Convert a string of the form '/.../Iixm' to a regular
    # expression. However, make the regular expression case-insensitive by
    # default and extend the modifier syntax to allow '/I' to indicate
    # case-sensitive.  Without the surrounding '/', quote any Regexp
    # metacharacters in the string and return a Regexp that matches the string
    # literally.
    #
    # @example
    #   '/Hello/'.as_regexp #=> /Hello/i
    #   '/Hello/I'.as_regexp #=> /Hello/
    #   'Hello'.as_regexp #=> /Hello/
    #   'Hello\b'.as_regexp #=> /Hello\\b/
    #
    # @return [Regexp]
    def as_regexp
      if self =~ %r{^\s*/([^/]*)/([Iixm]*)\s*$}
        body = $1
        opts = $2
        flags = Regexp::IGNORECASE
        unless opts.blank?
          flags = 0 if opts.include?('I')
          flags |= Regexp::IGNORECASE if opts.include?('i')
          flags |= Regexp::EXTENDED if opts.include?('x')
          flags |= Regexp::MULTILINE if opts.include?('m')
        end
        flags = nil if flags.zero?
        # body = Regexp.quote(body) if REGEXP_META_CHARACTERS.include?(body)
        Regexp.new(body, flags)
      else
        Regexp.new(Regexp.quote(self))
      end
    end

    # @group Numbers
    # :section: Numbers

    # Return whether self is convertible into a valid number.
    #
    # @example
    #   '6465321'.number?        #=> true
    #   '6465321.271828'.number? #=> true
    #   '76 trombones'           #=> false
    #   '2.77e7'                 #=> true
    #   '+12_534'                #=> true
    #
    # @return [Boolean] does self represent a valid number
    def number?
      Float(self)
      true
    rescue ArgumentError
      false
    end

    # If the string is a valid number, return a string that adds grouping commas
    # to the whole number part; otherwise, return self.  Round the number to the
    # given number places after the decimal if places is positive; round to the
    # left of the decimal if places is negative.  Pad with zeroes on the right
    # for positive places, on the left for negative places.
    #
    # @example
    #   'hello'.commas             #=> 'hello'
    #   '+4654656.33e66'.commas    #=> '+4,654,656.33e66'
    #   '6789345612.14'.commas(-5) #=> '6,789,350,000'
    #   '6543.14'.commas(5)        #=> '6,543.14000'
    #
    # @return [String] self if not a valid number
    # @return [String] commified number as a String
    def commas(places = nil)
      numeric_re = /\A([-+])?([\d_]*)((\.)?([\d_]*))?([eE][+-]?[\d_]+)?\z/
      return self unless clean =~ numeric_re

      sig = $1 || ''
      whole = $2 ? $2.delete('_') : ''
      frac = $5 || ''
      exp = $6 || ''

      # Round frac or whole if places given.  For positve places, round fraction
      # to that many places; for negative, round the whole-number part to the
      # absolute value of places left of the decimal.
      if places
        new_frac = frac.dup
        new_whole = whole.dup
        if places.zero?
          new_frac = ''
        elsif places.positive? && places < frac.length
          new_frac = frac[0...places - 1]
          new_frac[places - 1] =
            if frac[places].to_i >= 5
              (frac[places - 1].to_i + 1).to_s
            else
              frac[places - 1]
            end
        elsif places >= frac.length
          new_frac = frac + '0' * (places - frac.length)
        else
          # Negative places, round whole to places.abs from decimal
          places = places.abs
          if places > whole.length
            lead = whole[0].to_i >= 5 ? '1' : '0'
            new_whole[0] = places == whole.length + 1 ? lead : '0'
            new_whole[1..-1] = '0' * (places - 1)
            new_frac = ''
          elsif places > 1
            target = whole.length - places
            new_whole[target] =
              if whole[target + 1].to_i >= 5
                (whole[target].to_i + 1).to_s
              else
                whole[target]
              end
            new_whole[target + 1..whole.length - 1] =
              '0' * (whole.length - target - 1)
            new_frac = ''
          else
            # Rounding to 1 place, therefore, no rounding
            new_frac = ''
            new_whole = whole
          end
        end
        frac = new_frac
        whole = new_whole
      end

      # Place the commas in the whole part only
      whole = whole.reverse
      whole.gsub!(/([0-9]{3})/, '\\1,')
      whole.gsub!(/,$/, '')
      whole.reverse!

      # Reassemble
      if frac.blank?
        sig + whole + exp
      else
        sig + whole + '.' + frac + exp
      end
    end

    module ClassMethods
      # @group Generating
      # :section: Generating

      # Return a random string composed of all lower-case letters of length
      # `size`
      def random(size = 8)
        ('a'..'z').cycle.take(size).shuffle.join
      end
    end

    # @private
    def self.included(base)
      base.extend(ClassMethods)
    end
  end
end

class String
  include FatCore::String
  # @!parse include FatCore::String
  # @!parse extend FatCore::String::ClassMethods
end
