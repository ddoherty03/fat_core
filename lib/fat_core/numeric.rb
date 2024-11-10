# frozen_string_literal: true

require 'fat_core/patches'
require 'active_support/core_ext/object/blank'

module FatCore
  module Numeric
    # Return the signum function for this number, i.e., 1 for a positive number,
    # 0 for zero, and -1 for a negative number.
    #
    # @example
    #   -55.signum #=> -1
    #   0.signum   #=> 0
    #   55.signum  #=> 1
    #
    # @return [Integer] -1, 0, or 1 for negative, zero or positive self
    def signum
      raise NotImplementedError unless real?
      return 1 if positive?
      return -1 if negative?

      0
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
      return to_s if abs > 1.0 && to_s.include?('e')

      # Round if places given
      str =
        if places.nil?
          whole? ? to_i.to_s : to_f.to_s
        else
          to_f.round(places).to_s
        end

      # Break the number into parts; underscores are possible in all components.
      str =~ /\A(?<sg>[-+])?(?<wh>[\d_]*)((\.)?(?<fr>[\d_]*))?(?<ex>x[eE][+-]?[\d_]+)?\z/
      sig = Regexp.last_match[:sg] || ''
      whole = Regexp.last_match[:wh] ? Regexp.last_match[:wh].delete('_') : ''
      frac = Regexp.last_match[:fr] || ''
      exp = Regexp.last_match[:ex] || ''

      # Pad out the fractional part with zeroes to the right
      unless places.nil?
        n_zeroes = [places - frac.length, 0].max
        frac += '0' * n_zeroes if n_zeroes.positive?
      end

      # Place the commas in the whole part only
      whole = whole.reverse
      whole.gsub!(/([0-9]{3})/, "\\1#{delim}")
      whole.gsub!(/#{Regexp.escape(delim)}$/, '')
      whole.reverse!
      if frac.blank? # || places <= 0
        sig + whole + exp
      else
        sig + whole + '.' + frac + exp
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
        format(
          '%02<hrs>d:%02<mins>d:%02<secs>d.%<frac>d',
          {
            hrs: hrs,
            mins: mins,
            secs: secs,
            frac: frac.round(5) * 100
          },
        )
      else
        format(
          '%02<hrs>d:%02<mins>d:%02<secs>d',
          { hrs: hrs, mins: mins, secs: secs },
        )
      end
    end

    # Quote self for use in TeX documents.  Since number components are not
    # special to TeX, this just applies `#to_s`
    def tex_quote
      to_s.tex_quote
    end
  end
end

class Numeric
  include FatCore::Numeric
  # @!parse include FatCore::Numeric
  # @!parse extend FatCore::Numeric::ClassMethods
end
