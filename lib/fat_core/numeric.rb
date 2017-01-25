class Numeric
  def signum
    if self > 0
      1
    elsif self < 0
      -1
    else
      0
    end
  end

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
    frac += '0' * n_zeroes if n_zeroes > 0

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

  # Determine if this is a whole number.
  def whole?
    floor == self
  end

  # Return an integer type, but only if the fractional part of self
  # is zero
  def int_if_whole
    whole? ? floor : self
  end

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

  # Format the number according to the given sprintf format.  Besides the
  # sprintf formats, a format string of '%,2', for example, will return the
  # number grouped by commas and rounded to 2 places.  If no number of places
  # is given, the number will be rounded to an integer.
  def format_by(fmt = nil)
    return to_s unless fmt
    if /%,(?<places>\d*)/ =~ fmt.to_s.clean
      places ||= 0
      commas(places.to_i)
    else
      format fmt, self
    end
  end

  # Allow erb documents can directly interpolate numbers
  def tex_quote
    to_s
  end
end

class BigDecimal
  def inspect
    to_s
  end
end
