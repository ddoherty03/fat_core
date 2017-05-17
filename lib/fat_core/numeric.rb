module FatCore
  module Numeric
    # Return the signum function for this number, i.e., 1 for a positive number,
    # 0 for zero, and -1 for a negative number.
    def signum
      if positive?
        1
      elsif negative?
        -1
      else
        0
      end
    end

    # Convert this number into a string and insert grouping commas into the
    # whole number part and round the decimal part to `places` decimal places,
    # with the default number of places being zero for an integer and 4 for a
    # non-integer. The fractional part is padded with zeroes on the right to
    # come out to `places` digits after the decimal place.
    #
    # @example
    #   9324089.56.commas #=> '9,324,089.56'
    #   88883.14159.commas #=>'88,883.1416'
    #   88883.14159.commas(2) #=>'88,883.14'
    #
    # @param places [Integer] number of decimal place to round to
    # @return [String]
    def commas(places = nil)
      group(places, ',')
    end

    # Convert this number into a string and insert grouping delimiter character,
    # `delim` into the whole number part and round the decimal part to `places`
    # decimal places, with the default number of places being zero for an
    # integer and 4 for a non-integer. The fractional part is padded with zeroes
    # on the right to come out to `places` digits after the decimal place. This
    # is the same as #commas, but allows the delimiter to be any string.
    #
    # @example
    #   9324089.56.group          #=> '9,324,089.56'
    #   9324089.56.group(4)       #=> '9,324,089.5600'
    #   88883.14159.group         #=>'88,883.1416'
    #   88883.14159.group(2)      #=>'88,883.14'
    #   88883.14159.group(2, '_') #=>'88_883.14'
    #
    # @param places [Integer] number of decimal place to round to
    # @param delim [String] use delim as group separator
    # @return [String]
    def group(places = nil, delim = ',')
      # Return number as a string with embedded commas
      # for nice printing; round to places places after
      # the decimal

      # Only convert to string numbers with exponent unless they are
      # less than 1 (to ensure that really small numbers round to 0.0)
      return to_s if abs > 1.0 && to_s =~ /e/

      str = to_f.round(places).to_s

      # Break the number into parts
      str =~ /^(-)?(\d*)((\.)?(\d*))?$/
      neg = $1 || ''
      whole = $2
      frac = $5

      # Pad out the fractional part with zeroes to the right
      n_zeroes = [places - frac.length, 0].max
      frac += '0' * n_zeroes if n_zeroes.positive?

      # Place the commas in the whole part only
      whole = whole.reverse
      whole.gsub!(/([0-9]{3})/, "\\1#{delim}")
      whole.gsub!(/#{Regexp.escape(delim)}$/, '')
      whole.reverse!
      if frac.nil? || places <= 0
        neg + whole
      else
        neg + whole + '.' + frac
      end
    end

    # Return whether this is a whole number.
    #
    # @example
    #   23.45.whole? #=> false
    #   23.whole?    #=> true
    #
    # @return [Boolean] is self whole?
    def whole?
      floor == self
    end

    # Return an Integer type, but only if the fractional part of self is zero;
    # otherwise just return self.
    #
    # @example
    #   45.98.int_if_whole #=> 45.98
    #   45.000.int_if_whole #=> 45
    #
    # @return [Numeric, Integer]
    def int_if_whole
      whole? ? floor : self
    end

    # Convert self, regarded as a number of seconds, into a string of the form
    # HH:MM:SS.dd, that is to hours, minutes and seconds and fractions of seconds.
    #
    # @example
    #   5488.secs_to_hms #=> "01:31:28"
    #
    # @return [String] formatted as HH:MM:SS.dd
    def secs_to_hms
      frac = self % 1
      mins, secs = divmod(60)
      hrs, mins = mins.divmod(60)
      if frac.round(5) > 0.0
        '%02d:%02d:%02d.%d' % [hrs, mins, secs, frac.round(5) * 100]
      else
        '%02d:%02d:%02d' % [hrs, mins, secs]
      end
    end

    # Quote self for use in TeX documents.  Since number components are not
    # special to TeX, this just applies `#to_s`
    def tex_quote
      to_s
    end
  end
end

class Numeric
  include FatCore::Numeric
  # @!parse include FatCore::Numeric
  # @!parse extend FatCore::Numeric::ClassMethods
end
