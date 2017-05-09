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
    # whole number part and round the decimal part to +places+ decimal places,
    # with the number of places being zero for an integer and 4 for a
    # non-integer.
    def commas(places = nil)
      # By default, use zero places for whole numbers; four places for
      # numbers containing a fractional part to 4 places.
      if places.nil?
        places =
          if abs.modulo(1).round(4) > 0.0
            4
          else
            0
          end
      end
      group(places, ',')
    end

    # Convert this number into a string and insert grouping delimiter character,
    # +delim+ into the whole number part and round the decimal part to +places+
    # decimal places, with the number of places being zero for an integer and 4
    # for a non-integer.
    def group(places = 0, delim = ',')
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
    def whole?
      floor == self
    end

    # Return an Integer type, but only if the fractional part of self is zero;
    # otherwise just return self.
    def int_if_whole
      whole? ? floor : self
    end

    # Convert a number of seconds into a string of the form HH:MM:SS.dd, that is
    # to hours, minutes and seconds.
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

    # Allow erb documents to directly interpolate numbers
    def tex_quote
      to_s
    end
  end
end

Numeric.include FatCore::Numeric
