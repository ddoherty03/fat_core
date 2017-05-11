require 'date'
require 'active_support/core_ext/date'
require 'active_support/core_ext/time'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/integer/time'
require 'fat_core/string'

# ## FatCore Date Extensions
#
# The FatCore extensions to the Date class add the notion of several additional
# calendar periods besides years, months, and weeks to those provided for in the
# Date class and the active_support extensions to Date.  In particular, there
# are several additional calendar subdivisions (called "chunks" in this
# documentation) supported by FatCore's extension to the Date class:
#
# * year,
# * half,
# * quarter,
# * bimonth,
# * month,
# * semimonth,
# * biweek,
# * week, and
# * day
#
# For each of those chunks, there are methods for finding the beginning and end
# of the chunk, for advancing or retreating a Date by the chunk, and for testing
# whether a Date is at the beginning or end of each of the chunk.
#
# FatCore's Date extension defines a few convenience formatting methods, such as
# Date#iso and Date#org for formatting Dates as ISO strings and as Emacs
# org-mode inactive timestamps respectively. It also has a few utility methods
# for determining the date of Easter, the number of days in any given month, and
# the Date of the nth workday in a given month (say the third Thursday in
# October, 2014).
#
# The Date extension defines a couple of class methods for parsing strings into
# Dates, especially Date.parse_spec, which allows Dates to be specified in a
# lazy way, either absolutely or relative to the computer's clock.
#
# Finally FatCore's Date extensions provide thorough methods for determining if
# a Date is a United States federal holiday or workday based on US law,
# including executive orders. It does the same for the New York Stock Exchange,
# based on the rules of the New York Stock Exchange, including dates on which
# the NYSE was closed for special reasons, such as the 9-11 attacks in 2001.
class Date
  # Constant for Beginning of Time (BOT) outside the range of what we would ever
  # want to find in commercial situations.
  BOT = Date.parse('1900-01-01')

  # Constant for End of Time (EOT) outside the range of what we would ever want
  # to find in commercial situations.
  EOT = Date.parse('3000-12-31')

  # :category: Formatting
  # @group Formatting

  # Format as an ISO string of the form `YYYY-MM-DD`.
  # @return [String]
  def iso
    strftime('%Y-%m-%d')
  end

  # :category: Formatting

  # Format date to TeX documents as ISO strings
  # @return [String]
  def tex_quote
    iso
  end

  # :category: Formatting

  # Format as an all-numeric string of the form `YYYYMMDD`
  # @return [String]
  def num
    strftime('%Y%m%d')
  end

  # :category: Formatting

  # Format as an inactive Org date timestamp of the form `[YYYY-MM-DD <dow>]`
  # (see Emacs org-mode)
  # @return [String]
  def org
    strftime('[%Y-%m-%d %a]')
  end

  # :category: Formatting

  # Format as an English string, like `'January 12, 2016'`
  # @return [String]
  def eng
    strftime('%B %e, %Y')
  end

  # :category: Formatting

  # Format date in `MM/DD/YYYY` form, as typical for the short American
  # form.
  # @return [String]
  def american
    strftime '%-m/%-d/%Y'
  end

  # :category: Queries
  # @group Queries

  # Does self fall on a weekend?
  # @return [Boolean]
  def weekend?
    saturday? || sunday?
  end

  # :category: Queries

  # Does self fall on a weekday?
  # @return [Boolean]
  def weekday?
    !weekend?
  end

  # :category: Queries

  # Self's calendar "half" by analogy to calendar quarters: 1 or 2, depending
  # on whether the date falls in the first or second half of the calendar
  # year.
  # @return [1, 2]
  def half
    case month
    when (1..6)
      1
    when (7..12)
      2
    end
  end

  # :category: Queries

  # Self's calendar quarter: 1, 2, 3, or 4, depending on which calendar quarter
  # the date falls in.
  # @return [1, 2, 3, 4]
  def quarter
    case month
    when (1..3)
      1
    when (4..6)
      2
    when (7..9)
      3
    when (10..12)
      4
    end
  end

  # :category: Queries

  # Return whether the date falls on the first day of a year.
  # @return [Boolean]
  def beginning_of_year?
    beginning_of_year == self
  end

  # :category: Queries

  # Return whether the date falls on the last day of a year.
  # @return [Boolean]
  def end_of_year?
    end_of_year == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a half-year.
  # @return [Boolean]
  def beginning_of_half?
    beginning_of_half == self
  end

  # :category: Queries

  # Return whether the date falls on the last day of a half-year.
  # @return [Boolean]
  def end_of_half?
    end_of_half == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a calendar quarter.
  # @return [Boolean]
  def beginning_of_quarter?
    beginning_of_quarter == self
  end

  # :category: Queries

  # Return whether the date falls on the last day of a calendar quarter.
  # @return [Boolean]
  def end_of_quarter?
    end_of_quarter == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a calendar bi-monthly
  # period, i.e., the beginning of an odd-numbered month.
  # @return [Boolean]
  def beginning_of_bimonth?
    month.odd? && beginning_of_month == self
  end

  # :category: Queries

  # Return whether the date falls on the last day of a calendar bi-monthly
  # period, i.e., the end of an even-numbered month.
  # @return [Boolean]
  def end_of_bimonth?
    month.even? && end_of_month == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a calendar month.
  # @return [Boolean]
  def beginning_of_month?
    beginning_of_month == self
  end

  # :category: Queries

  # Return whether the date falls on the last day of a calendar month.
  # @return [Boolean]
  def end_of_month?
    end_of_month == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a calendar semi-monthly
  # period, i.e., on the 1st or 15th of a month.
  # @return [Boolean]
  def beginning_of_semimonth?
    beginning_of_semimonth == self
  end

  # :category: Queries

  # Return whether the date falls on the last day of a calendar semi-monthly
  # period, i.e., on the 14th or the last day of a month.
  # @return [Boolean]
  def end_of_semimonth?
    end_of_semimonth == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a commercial bi-week,
  # i.e., on /Monday/ in a commercial week that is an odd-numbered week. From
  # Date: "The calendar week is a seven day period within a calendar year,
  # starting on a Monday and identified by its ordinal number within the year;
  # the first calendar week of the year is the one that includes the first
  # Thursday of that year. In the Gregorian calendar, this is equivalent to
  # the week which includes January 4."
  # @return [Boolean]
  def beginning_of_biweek?
    beginning_of_biweek == self
  end

  # :category: Queries

  # Return whether the date falls on the last day of a commercial bi-week,
  # i.e., on /Sunday/ in a commercial week that is an even-numbered week. From
  # Date: "The calendar week is a seven day period within a calendar year,
  # starting on a Monday and identified by its ordinal number within the year;
  # the first calendar week of the year is the one that includes the first
  # Thursday of that year. In the Gregorian calendar, this is equivalent to
  # the week which includes January 4."
  # @return [Boolean]
  def end_of_biweek?
    end_of_biweek == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a commercial week, i.e.,
  # on /Monday/ in a commercial week. From Date: "The calendar week is a seven
  # day period within a calendar year, starting on a Monday and identified by
  # its ordinal number within the year; the first calendar week of the year is
  # the one that includes the first Thursday of that year. In the Gregorian
  # calendar, this is equivalent to the week which includes January 4."
  # @return [Boolean]
  def beginning_of_week?
    beginning_of_week == self
  end

  # :category: Queries

  # Return whether the date falls on the first day of a commercial week, i.e.,
  # on /Sunday/ in a commercial week. From Date: "The calendar week is a seven
  # day period within a calendar year, starting on a Monday and identified by
  # its ordinal number within the year; the first calendar week of the year is
  # the one that includes the first Thursday of that year. In the Gregorian
  # calendar, this is equivalent to the week which includes January 4."
  # @return [Boolean]
  def end_of_week?
    end_of_week == self
  end

  # Return whether this date falls within a period of *less* than six months
  # from the date `d` using the *Stella v. Graham Page Motors* convention that
  # "less" than six months is true only if this date falls within the range of
  # dates 2 days after date six months before and 2 days before the date six
  # months after the date `d`.
  #
  # @param d [Date] the middle of the six-month range
  # @return [Boolean]
  def within_6mos_of?(d)
    # Date 6 calendar months before self
    start_date = self - 6.months + 2.days
    end_date = self + 6.months - 2.days
    (start_date..end_date).cover?(d)
  end

  # Return whether this date is Easter Sunday for the year in which it falls
  # according to the Western Church.  A few holidays key off this date as
  # "moveable feasts."
  #
  # @return [Boolean]
  def easter?
    # Am I Easter?
    self == easter_this_year
  end

  # Return whether this date is the `n`th weekday `wday` of the given `month` in
  # this date's year.
  #
  # @param n [Integer] number of wday in month, if negative count from end of
  #   the month
  # @param wday [Integer] day of week, 0 is Sunday, 1 Monday, etc.
  # @param month [Integer] the month number, 1 is January, 2 is February, etc.
  # @return [Boolean]
  def nth_wday_in_month?(n, wday, month)
    # Is self the nth weekday in the given month of its year?
    # If n is negative, count from last day of month
    self == ::Date.nth_wday_in_year_month(n, wday, year, month)
  end

  # :category: Relative Dates
  # @group Relative Dates

  # Predecessor of self, opposite of `#succ`.
  # @return [Date]
  def pred
    self - 1.day
  end

  # Note: the Date class already has a #succ method.

  # The date that is the first day of the half-year in which self falls.
  # @return [Date]
  def beginning_of_half
    if month > 9
      (beginning_of_quarter - 15).beginning_of_quarter
    elsif month > 6
      beginning_of_quarter
    else
      beginning_of_year
    end
  end

  # :category: Relative Dates

  # The date that is the last day of the half-year in which self falls.
  # @return [Date]
  def end_of_half
    if month < 4
      (end_of_quarter + 15).end_of_quarter
    elsif month < 7
      end_of_quarter
    else
      end_of_year
    end
  end

  # :category: Relative Dates

  # The date that is the first day of the bimonth in which self
  # falls. A 'bimonth' is a two-month calendar period beginning on the
  # first day of the odd-numbered months.  E.g., 2014-01-01 to
  # 2014-02-28 is the first bimonth of 2014.
  # @return [Date]
  def beginning_of_bimonth
    if month.odd?
      beginning_of_month
    else
      (self - 1.month).beginning_of_month
    end
  end

  # :category: Relative Dates

  # The date that is the last day of the bimonth in which self falls.
  # A 'bimonth' is a two-month calendar period beginning on the first
  # day of the odd-numbered months.  E.g., 2014-01-01 to 2014-02-28 is
  # the first bimonth of 2014.
  # @return [Date]
  def end_of_bimonth
    if month.odd?
      (self + 1.month).end_of_month
    else
      end_of_month
    end
  end

  # :category: Relative Dates

  # The date that is the first day of the semimonth in which self
  # falls.  A semimonth is a calendar period beginning on the 1st or
  # 16th of each month and ending on the 15th or last day of the month
  # respectively.  So each year has exactly 24 semimonths.
  # @return [Date]
  def beginning_of_semimonth
    if day >= 16
      ::Date.new(year, month, 16)
    else
      beginning_of_month
    end
  end

  # :category: Relative Dates

  # The date that is the last day of the semimonth in which self
  # falls.  A semimonth is a calendar period beginning on the 1st or
  # 16th of each month and ending on the 15th or last day of the month
  # respectively.  So each year has exactly 24 semimonths.
  # @return [Date]
  def end_of_semimonth
    if day <= 15
      ::Date.new(year, month, 15)
    else
      end_of_month
    end
  end

  # :category: Relative Dates

  # Return the date that is the first day of the commercial biweek in which
  # self falls. A biweek is a period of two commercial weeks starting with an
  # odd-numbered week and with each week starting in Monday and ending on
  # Sunday.
  # @return [Date]
  def beginning_of_biweek
    if cweek.odd?
      beginning_of_week(:monday)
    else
      (self - 1.week).beginning_of_week(:monday)
    end
  end

  # :category: Relative Dates

  # Return the date that is the last day of the commercial biweek in which
  # self falls. A biweek is a period of two commercial weeks starting with an
  # odd-numbered week and with each week starting in Monday and ending on
  # Sunday. So this will always return a Sunday in an even-numbered week.
  # @return [Date]
  def end_of_biweek
    if cweek.odd?
      (self + 1.week).end_of_week(:monday)
    else
      end_of_week(:monday)
    end
  end

  # Return the date that is +n+ calendar halves after this date, where a
  # calendar half is a period of 6 months.
  #
  # @param n [Integer] number of halves to advance, can be negative
  # @return [Date] new date n halves after this date
  def next_half(n = 1)
    n = n.floor
    return self if n.zero?
    next_month(n * 6)
  end

  # Return the date that is +n+ calendar halves before this date, where a
  # calendar half is a period of 6 months.
  #
  # @param n [Integer] number of halves to retreat, can be negative
  # @return [Date] new date n halves before this date
  def prior_half(n = 1)
    next_half(-n)
  end

  # Return the date that is +n+ calendar quarters after this date, where a
  # calendar quarter is a period of 3 months.
  #
  # @param n [Integer] number of quarters to advance, can be negative
  # @return [Date] new date n quarters after this date
  def next_quarter(n = 1)
    n = n.floor
    return self if n.zero?
    next_month(n * 3)
  end

  # Return the date that is +n+ calendar quarters before this date, where a
  # calendar quarter is a period of 3 months.
  #
  # @param n [Integer] number of quarters to retreat, can be negative
  # @return [Date] new date n quarters after this date
  def prior_quarter(n = 1)
    next_quarter(-n)
  end

  # Return the date that is +n+ calendar bimonths after this date, where a
  # calendar bimonth is a period of 2 months.
  #
  # @param n [Integer] number of bimonths to advance, can be negative
  # @return [Date] new date n bimonths after this date
  def next_bimonth(n = 1)
    n = n.floor
    return self if n.zero?
    next_month(n * 2)
  end

  # Return the date that is +n+ calendar bimonths before this date, where a
  # calendar bimonth is a period of 2 months.
  #
  # @param n [Integer] number of bimonths to retreat, can be negative
  # @return [Date] new date n bimonths before this date
  def prior_bimonth(n = 1)
    next_bimonth(-n)
  end

  # Return the date that is +n+ semimonths after this date. Each semimonth begins
  # on the 1st or 16th of the month, and advancing one semimonth from the first
  # half of a month means to go as far past the 16th as the current date is past
  # the 1st; advancing one semimonth from the second half of a month means to go
  # as far into the next month past the 1st as the current date is past the
  # 16th, but never past the 15th of the next month.
  #
  # @param n [Integer] number of semimonths to advance, can be negative
  # @return [Date] new date n semimonths after this date
  def next_semimonth(n = 1)
    n = n.floor
    return self if n.zero?
    factor = n.negative? ? -1 : 1
    n = n.abs
    if n.even?
      next_month(n / 2)
    else
      # Advance or retreat one semimonth
      next_sm =
        if day == 1
          if factor.positive?
            beginning_of_month + 16.days
          else
            prior_month.beginning_of_month + 16.days
          end
        elsif day == 16
          if factor.positive?
            next_month.beginning_of_month
          else
            beginning_of_month
          end
        elsif day < 16
          # In the first half of the month (the 2nd to the 15th), go as far past
          # the 16th as the date is past the 1st. Thus, as many as 14 days past
          # the 16th, so at most to the 30th of the month unless there are less
          # than 30 days in the month, then go to the end of the month.
          if factor.positive?
            [beginning_of_month + 16.days + (day - 1).days, end_of_month].min
          else
            [prior_month.beginning_of_month + 16.days + (day - 1).days,
             prior_month.end_of_month].min
          end
        else
          # In the second half of the month (17th to the 31st), go as many
          # days into the next month as we are past the 16th. Thus, as many as
          # 15 days.  But we don't want to go past the first half of the next
          # month, so we only go so far as the 15th of the next month.
          # Date.parse('2015-02-18').next_semimonth should be the 3rd of the
          # following month.
          if factor.positive?
            next_month.beginning_of_month + [(day - 16), 15].min
          else
            beginning_of_month + [(day - 16), 15].min
          end
        end
      n -= 1
      # Now that n is even, advance (or retreat) n / 2 months unless we're done.
      if n >= 2
        next_sm.next_month(factor * n / 2)
      else
        next_sm
      end
    end
  end

  # Return the date that is +n+ semimonths before this date. Each semimonth
  # begins on the 1st or 15th of the month, and retreating one semimonth from
  # the first half of a month means to go as far past the 15th of the prior
  # month as the current date is past the 1st; retreating one semimonth from the
  # second half of a month means to go as far past the 1st of the current month
  # as the current date is past the 15th, but never past the 14th of the the
  # current month.
  #
  # @param n [Integer] number of semimonths to retreat, can be negative
  # @return [Date] new date n semimonths before this date
  def prior_semimonth(n = 1)
    next_semimonth(-n)
  end

  # Return the date that is +n+ biweeks after this date where each biweek is 14
  # days.
  #
  # @param n [Integer] number of biweeks to advance, can be negative
  # @return [Date] new date n biweeks after this date
  def next_biweek(n = 1)
    n = n.floor
    return self if n.zero?
    self + (14 * n)
  end

  # Return the date that is +n+ biweeks before this date where each biweek is 14
  # days.
  #
  # @param n [Integer] number of biweeks to retreat, can be negative
  # @return [Date] new date n biweeks before this date
  def prior_biweek(n = 1)
    next_biweek(-n)
  end

  # Return the date that is +n+ weeks after this date where each week is 7 days.
  # This is different from the #next_week method in active_support, which
  # goes to the first day of the week in the next week and does not take an
  # argument +n+ to go multiple weeks.
  #
  # @param n [Integer] number of weeks to advance
  # @return [Date] new date n weeks after this date
  def next_week(n = 1)
    n = n.floor
    return self if n.zero?
    self + (7 * n)
  end

  # Return the date that is +n+ weeks before this date where each week is 7
  # days.
  #
  # @param n [Integer] number of weeks to retreat
  # @return [Date] new date n weeks from this date
  def prior_week(n)
    next_week(-n)
  end

  # NOTE: #next_day is defined in active_support.

  # Return the date that is +n+ weeks before this date where each week is 7
  # days.
  #
  # @param n [Integer] number of days to retreat
  # @return [Date] new date n days before this date
  def prior_day(n)
    next_day(-n)
  end

  # :category: Relative Dates

  # Return the date that is n chunks later than self.
  #
  # @param chunk [Symbol] one of +:year+, +:half+, +:quarter+, +:bimonth+,
  #   +:month+, +:semimonth+, +:biweek+, +:week+, or +:day+.
  # @param n [Integer] the number of chunks to add, can be negative
  # @return [Date] the date n chunks from this date
  def add_chunk(chunk, n = 1)
    case chunk
    when :year
      next_year(n)
    when :half
      next_month(6)
    when :quarter
      next_month(3)
    when :bimonth
      next_month(2)
    when :month
      next_month(n)
    when :semimonth
      next_semimonth(n)
    when :biweek
      next_biweek(n)
    when :week
      next_week(n)
    when :day
      next_day(n)
    else
      raise ArgumentError, "add_chunk unknown chunk: '#{chunk}'"
    end
  end

  # Return the date that is the beginning of the +chunk+ in which this date
  # falls.
  #
  # @param chunk [Symbol] one of +:year+, +:half+, +:quarter+, +:bimonth+,
  #   +:month+, +:semimonth+, +:biweek+, +:week+, or +:day+.
  # @return [Date] the first date in the chunk-sized period in which this date
  #   falls
  def beginning_of_chunk(chunk)
    case chunk
    when :year
      beginning_of_year
    when :half
      beginning_of_half
    when :quarter
      beginning_of_quarter
    when :bimonth
      beginning_of_bimonth
    when :month
      beginning_of_month
    when :semimonth
      beginning_of_semimonth
    when :biweek
      beginning_of_biweek
    when :week
      beginning_of_week
    when :day
      self
    else
      raise ArgumentError, "unknown chunk sym: '#{chunk}'"
    end
  end

  # Return the date that is the end of the +chunk+ in which this date
  # falls.
  #
  # @param chunk [Symbol] one of +:year+, +:half+, +:quarter+, +:bimonth+,
  #   +:month+, +:semimonth+, +:biweek+, +:week+, or +:day+.
  # @return [Date] the first date in the chunk-sized period in which this date
  #   falls
  def end_of_chunk(sym)
    case sym
    when :year
      end_of_year
    when :half
      end_of_half
    when :quarter
      end_of_quarter
    when :bimonth
      end_of_bimonth
    when :month
      end_of_month
    when :semimonth
      end_of_semimonth
    when :biweek
      end_of_biweek
    when :week
      end_of_week
    when :day
      self
    else
      raise ArgumentError, "unknown chunk sym: '#{sym}'"
    end
  end

  # Return the date for Easter in the Western Church for the year in which this
  # date falls.
  #
  # @return [Date]
  def easter_this_year
    # Return the date of Easter in self's year
    Date.easter(year)
  end

  # @group Federal Holidays and Workdays

  # Holidays decreed by executive order See http://www.whitehouse.gov/the-press-office/2012/12/21
  FED_DECREED_HOLIDAYS =
    [
      ::Date.parse('2012-12-24')
    ].freeze

  # Return whether this date is a United States federal holiday.
  #
  # Calculations for Federal holidays are based on 5 USC 6103, include all
  # weekends, and holidays based on executive orders.
  #
  # @return [Boolean]
  def fed_holiday?
    # All Saturdays and Sundays are "holidays"
    return true if weekend?

    # Some days are holidays by executive decree
    return true if FED_DECREED_HOLIDAYS.include?(self)

    # Is self a fixed holiday
    return true if fed_fixed_holiday? || fed_moveable_feast?

    if friday? && month == 12 && day == 26
      # If Christmas falls on a Thursday, apparently, the Friday after is
      # treated as a holiday as well.  See 2003, 2008, for example.
      true
    elsif friday?
      # A Friday is a holiday if a fixed-date holiday
      # would fall on the following Saturday
      (self + 1).fed_fixed_holiday? || (self + 1).fed_moveable_feast?
    elsif monday?
      # A Monday is a holiday if a fixed-date holiday
      # would fall on the preceding Sunday
      (self - 1).fed_fixed_holiday? || (self - 1).fed_moveable_feast?
    else
      false
    end
  end

  # Return whether this date is a date on which the US federal government is
  # open for business.  It is the opposite of #fed_holiday?
  #
  # @return [Boolean]
  def fed_workday?
    !fed_holiday?
  end

  # :category: Queries

  # Return the date that is n federal workdays after or before (if n < 0) this
  # date.
  #
  # @param n [Integer] number of federal workdays to add to this date
  # @return [Date]
  def add_fed_workdays(n)
    d = dup
    return d if n.zero?
    incr = n.negative? ? -1 : 1
    n = n.abs
    while n.positive?
      d += incr
      n -= 1 if d.fed_workday?
    end
    d
  end

  # Return the next federal workday after this date. The date returned is always
  # a date at least one day after this date, never this date.
  #
  # @return [Date]
  def next_fed_workday
    add_fed_workdays(1)
  end

  # Return the last federal workday before this date.  The date returned is always
  # a date at least one day before this date, never this date.
  #
  # @return [Date]
  def prior_fed_workday
    add_fed_workdays(-1)
  end

  # Return this date if its a federal workday, otherwise skip forward to the
  # first later federal workday.
  #
  # @return [Date]
  def next_until_fed_workday
    date = dup
    date += 1 until date.fed_workday?
    date
  end

  # Return this if its a federal workday, otherwise skip back to the first prior
  # federal workday.
  def prior_until_fed_workday
    date = dup
    date -= 1 until date.fed_workday?
    date
  end

  protected

  def fed_fixed_holiday?
    # Fixed-date holidays on weekdays
    if mon == 1 && mday == 1
      # New Years (January 1),
      true
    elsif mon == 7 && mday == 4
      # Independence Day (July 4),
      true
    elsif mon == 11 && mday == 11
      # Veterans Day (November 11),
      true
    elsif mon == 12 && mday == 25
      # Christmas (December 25), and
      true
    else
      false
    end
  end

  def fed_moveable_feast?
    # See if today is a "movable feast," all of which are
    # rigged to fall on Monday except Thanksgiving

    # No moveable feasts in certain months
    if [3, 4, 6, 7, 8, 12].include?(month)
      false
    elsif monday?
      moveable_mondays = []
      # MLK's Birthday (Third Monday in Jan)
      moveable_mondays << nth_wday_in_month?(3, 1, 1)
      # Washington's Birthday (Third Monday in Feb)
      moveable_mondays << nth_wday_in_month?(3, 1, 2)
      # Memorial Day (Last Monday in May)
      moveable_mondays << nth_wday_in_month?(-1, 1, 5)
      # Labor Day (First Monday in Sep)
      moveable_mondays << nth_wday_in_month?(1, 1, 9)
      # Columbus Day (Second Monday in Oct)
      moveable_mondays << nth_wday_in_month?(2, 1, 10)
      # Other Mondays
      moveable_mondays.any?
    elsif thursday?
      # Thanksgiving Day (Fourth Thur in Nov)
      nth_wday_in_month?(4, 4, 11)
    else
      false
    end
  end

  # @group NYSE Holidays and Workdays

  # :category: Queries

  public

  # Returns whether this date is one on which the NYSE was or is expected to be
  # closed for business.
  #
  # Calculations for NYSE holidays are from Rule 51 and supplementary materials
  # for the Rules of the New York Stock Exchange, Inc.
  #
  # * General Rule 1: if a regular holiday falls on Saturday, observe it on the preceding Friday.
  # * General Rule 2: if a regular holiday falls on Sunday, observe it on the following Monday.
  #
  # These are the regular holidays:
  #
  # * New Year's Day, January 1.
  # * Birthday of Martin Luther King, Jr., the third Monday in January.
  # * Washington's Birthday, the third Monday in February.
  # * Good Friday Friday before Easter Sunday.  NOTE: this is not a fed holiday
  # * Memorial Day, the last Monday in May.
  # * Independence Day, July 4.
  # * Labor Day, the first Monday in September.
  # * Thanksgiving Day, the fourth Thursday in November.
  # * Christmas Day, December 25.
  #
  # Columbus and Veterans days not observed.
  #
  # In addition, there have been several days on which the exchange has been
  # closed for special events such as Presidential funerals, the 9-11 attacks,
  # the paper-work crisis in the 1960's, hurricanes, etc.  All of these are
  # considered holidays for purposes of this method.
  #
  # In addition, every weekend is considered a holiday.
  #
  # @return [Boolean]
  def nyse_holiday?
    # All Saturdays and Sundays are "holidays"
    return true if weekend?

    # Is self a fixed holiday
    return true if nyse_fixed_holiday? || nyse_moveable_feast?

    return true if nyse_special_holiday?

    if friday? && (self >= ::Date.parse('1959-07-03'))
      # A Friday is a holiday if a holiday would fall on the following
      # Saturday.  The rule does not apply if the Friday "ends a monthly or
      # yearly accounting period." Adopted July 3, 1959. E.g, December 31,
      # 2010, fell on a Friday, so New Years was on Saturday, but the NYSE
      # opened because it ended a yearly accounting period.  I believe 12/31
      # is the only date to which the exception can apply since only New
      # Year's can fall on the first of the month.
      !end_of_quarter? &&
        ((self + 1).nyse_fixed_holiday? || (self + 1).nyse_moveable_feast?)
    elsif monday?
      # A Monday is a holiday if a holiday would fall on the
      # preceding Sunday.  This has apparently always been the rule.
      (self - 1).nyse_fixed_holiday? || (self - 1).nyse_moveable_feast?
    else
      false
    end
  end

  # Return whether the NYSE is open for trading on this date.
  #
  # @return [Boolean]
  def nyse_workday?
    !nyse_holiday?
  end
  alias trading_day? nyse_workday?

  # Return the date that is n NYSE trading days after or before (if n < 0) this
  # date.
  #
  # @param n [Integer] number of NYSE trading days to add to this date
  # @return [Date]
  def add_nyse_workdays(n)
    d = dup
    return d if n.zero?
    incr = n.negative? ? -1 : 1
    n = n.abs
    while n.positive?
      d += incr
      n -= 1 if d.nyse_workday?
    end
    d
  end
  alias add_trading_days add_nyse_workdays

  # Return the next NYSE trading day after this date. The date returned is always
  # a date at least one day after this date, never this date.
  #
  # @return [Date]
  def next_nyse_workday
    add_nyse_workdays(1)
  end
  alias next_trading_day next_nyse_workday

  # Return the last NYSE trading day before this date. The date returned is always
  # a date at least one day before this date, never this date.
  #
  # @return [Date]
  def prior_nyse_workday
    add_nyse_workdays(-1)
  end
  alias prior_trading_day prior_nyse_workday

  # Return this date if its a trading day, otherwise skip forward to the first
  # later trading day.
  #
  # @return [Date]
  def next_until_trading_day
    date = dup
    date += 1 until date.trading_day?
    date
  end

  # Return this date if its a trading day, otherwise skip back to the first prior
  # trading day.
  #
  # @return [Date]
  def prior_until_trading_day
    date = dup
    date -= 1 until date.trading_day?
    date
  end

  protected

  def nyse_fixed_holiday?
    # Fixed-date holidays
    if mon == 1 && mday == 1
      # New Years (January 1),
      true
    elsif mon == 7 && mday == 4
      # Independence Day (July 4),
      true
    elsif mon == 12 && mday == 25
      # Christmas (December 25), and
      true
    else
      false
    end
  end

  # :category: Queries

  def nyse_moveable_feast?
    # See if today is a "movable feast," all of which are
    # rigged to fall on Monday except Thanksgiving

    # No moveable feasts in certain months
    return false if [6, 7, 8, 10, 12].include?(month)

    case month
    when 1
      # MLK's Birthday (Third Monday in Jan) since 1998
      year >= 1998 && nth_wday_in_month?(3, 1, 1)
    when 2
      # Lincoln's birthday until 1953
      # Washington's Birthday (Third Monday in Feb)
      (year <= 1953 && month == 2 && day == 12) ||
        (year <= 1970 ? (month == 2 && day == 22)
         : nth_wday_in_month?(3, 1, 2))
    when 3, 4
      # Good Friday
      if !friday?
        false
      elsif [1898, 1906, 1907].include?(year)
        # Good Friday, the Friday before Easter, except certain years
        false
      else
        (self + 2).easter?
      end
    when 5
      # Memorial Day (Last Monday in May)
      year <= 1970 ? (month == 5 && day == 30) : nth_wday_in_month?(-1, 1, 5)
    when 9
      # Labor Day (First Monday in Sep)
      nth_wday_in_month?(1, 1, 9)
    when 10
      # Columbus Day (Oct 12) 1909--1953
      year >= 1909 && year <= 1953 && day == 12
    when 11
      if tuesday?
        # Election Day. Until 1968 all Election Days.  From 1972 to 1980
        # Election Day in presidential years only.  Election Day is the first
        # Tuesday after the first Monday in November.
        first_tuesday = ::Date.nth_wday_in_year_month(1, 1, year, 11) + 1
        is_election_day = (self == first_tuesday)
        if year <= 1968
          is_election_day
        elsif year <= 1980
          is_election_day && (year % 4).zero?
        else
          false
        end
      elsif thursday?
        # Historically Thanksgiving (NYSE closed all day) had been declared to
        #   be the last Thursday in November until 1938; the next-to-last
        #   Thursday in November from 1939 to 1941 (therefore the 3rd Thursday
        #   in 1940 and 1941); the last Thursday in November in 1942; the fourth
        #   Thursday in November since 1943;
        if year < 1938
          nth_wday_in_month?(-1, 4, 11)
        elsif year <= 1941
          nth_wday_in_month?(3, 4, 11)
        elsif year == 1942
          nth_wday_in_month?(-1, 4, 11)
        else
          nth_wday_in_month?(4, 4, 11)
        end
      elsif day == 11
        # Armistice or Veterans Day.  1918--1921; 1934--1953.
        (year >= 1918 && year <= 1921) || (year >= 1934 && year <= 1953)
      else
        false
      end
    else
      false
    end
  end

  # :category: Queries

  # They NYSE has closed on several occasions outside its normal holiday
  # rules.  This detects those dates beginning in 1960.  Closing for part of a
  # day is not counted. See http://www1.nyse.com/pdfs/closings.pdf
  def nyse_special_holiday?
    return false unless self > ::Date.parse('1960-01-01')
    case self
    when ::Date.parse('1961-05-29')
      # Day before Decoaration Day
      true
    when ::Date.parse('1963-11-25')
      # President Kennedy's funeral
      true
    when ::Date.parse('1965-12-24')
      # Christmas eve unscheduled for normal holiday
      true
    when ::Date.parse('1968-02-12')
      # Lincoln birthday
      true
    when ::Date.parse('1968-04-09')
      # Mourning MLK
      true
    when ::Date.parse('1968-07-05')
      # Day after Independence Day
      true
    when (::Date.parse('1968-06-12')..::Date.parse('1968-12-31'))
      # Paperwork crisis (closed on Wednesdays if no other holiday in week)
      wednesday? && (self - 2).nyse_workday? && (self - 1).nyse_workday? &&
        (self + 1).nyse_workday? && (self + 2).nyse_workday?
    when ::Date.parse('1969-02-10')
      # Heavy snow
      true
    when ::Date.parse('1969-05-31')
      # Eisenhower Funeral
      true
    when ::Date.parse('1969-07-21')
      # Moon landing
      true
    when ::Date.parse('1972-12-28')
      # Truman Funeral
      true
    when ::Date.parse('1973-01-25')
      # Johnson Funeral
      true
    when ::Date.parse('1977-07-14')
      # Electrical blackout NYC
      true
    when ::Date.parse('1985-09-27')
      # Hurricane Gloria
      true
    when ::Date.parse('1994-04-27')
      # Nixon Funeral
      true
    when (::Date.parse('2001-09-11')..::Date.parse('2001-09-14'))
      # 9-11 Attacks
      a = a
      true
    when (::Date.parse('2004-06-11')..::Date.parse('2001-09-14'))
      # Reagan Funeral
      true
    when ::Date.parse('2007-01-02')
      # Observance death of President Ford
      true
    when ::Date.parse('2012-10-29'), ::Date.parse('2012-10-30')
      # Hurricane Sandy
      true
    else
      false
    end
  end

  class << self
    # @group Parsing
    #
    # Convert a string +str+ with an American style date into a Date object
    #
    # An American style date is of the form `MM/DD/YYYY`, that is it places the
    # month first, then the day of the month, and finally the year. The European
    # convention is to place the day of the month first, `DD/MM/YYYY`. A date
    # found in the wild can be ambiguous, e.g. 3/5/2014, but a date string known
    # to be using the American convention can be parsed using this method. Both
    # the month and the day can be a single digit. The year can be either 2 or 4
    # digits, and if given as 2 digits, it adds 2000 to it to give the year.
    #
    # @example
    #   Date.parse_american('9/11/2001') #=> Date(2011, 9, 11)
    #   Date.parse_american('9/11/01')   #=> Date(2011, 9, 11)
    #   Date.parse_american('9/11/1')    #=> ArgumentError
    #
    # @param str [String, #to_s] a stringling of the form MM/DD/YYYY
    # @return [Date] the date represented by the str paramenter.
    def parse_american(str)
      unless str.to_s =~ %r{\A\s*(\d\d?)\s*/\s*(\d\d?)\s*/\s*((\d\d)?\d\d)\s*\z}
        raise ArgumentError, "date string must be of form 'MM?/DD?/YY(YY)?'"
      end
      year = $3.to_i
      month = $1.to_i
      day = $2.to_i
      year += 2000 if year < 100
      Date.new(year, month, day)
    end

    # Convert a 'date spec' +spec+ to a Date.  A date spec is a short-hand way of
    # specifying a date, relative to the computer clock.  A date spec can
    # interpreted as either a 'from spec' or a 'to spec'.
    #
    # Assuming that Date.current at the time of execution is 2014-07-26 and
    # using the default spec_type of :from.  The return values are actually Date
    # objects, but are shown below as textual dates.
    #
    # @example
    #   A fully specified date returns that date:
    #   Date.parse_spec('2001-09-11')  # =>
    #
    # Commercial weeks can be specified using, for example W32 or 32W, with the
    # week beginning on Monday, ending on Sunday.
    #
    # @example
    #   Date.parse_spec('2012-W32').iso      # => "2012-08-06"
    #   Date.parse_spec('2012-W32', :to).iso # => "2012-08-12"
    #   Date.parse_spec('W32')               # => "2012-08-06" if executed in 2012
    #
    # A spec of the form Q3 or 3Q returns the beginning or end of calendar
    # quarters.
    # @example
    #     Date.parse_spec('Q3')         # =>
    #
    # @param spec [#to_s] the spec to be interpreted as a calendar period
    #
    # @param spec_type [:from, :to] return the first (:from) or last (:to)
    #   date in the spec's period respectively
    #
    # @return [Date] date that is the first (:from) or last (:to) in the period
    #   designated by `spec`
    def parse_spec(spec, spec_type = :from)
      spec = spec.to_s.strip
      unless [:from, :to].include?(spec_type)
        raise ArgumentError, "invalid date spec type: '#{spec_type}'"
      end

      today = ::Date.current
      case spec.clean
      when /\A(\d\d\d\d)[-\/](\d\d?)[-\/](\d\d?)\z/
        # A specified date
        ::Date.new($1.to_i, $2.to_i, $3.to_i)
      when /\AW(\d\d?)\z/, /\A(\d\d?)W\z/
        week_num = $1.to_i
        if week_num < 1 || week_num > 53
          raise ArgumentError, "invalid week number (1-53): 'W#{week_num}'"
        end
        if spec_type == :from
          ::Date.commercial(today.year, week_num).beginning_of_week
        else
          ::Date.commercial(today.year, week_num).end_of_week
        end
      when /\A(\d\d\d\d)[-\/]W(\d\d?)\z/, /\A(\d\d\d\d)[-\/](\d\d?)W\z/
        year = $1.to_i
        week_num = $2.to_i
        if week_num < 1 || week_num > 53
          raise ArgumentError, "invalid week number (1-53): 'W#{week_num}'"
        end
        if spec_type == :from
          ::Date.commercial(year, week_num).beginning_of_week
        else
          ::Date.commercial(year, week_num).end_of_week
        end
      when /^(\d\d\d\d)[-\/](\d)[Qq]$/, /^(\d\d\d\d)[-\/][Qq](\d)$/
        # Year-Quarter
        year = $1.to_i
        quarter = $2.to_i
        unless [1, 2, 3, 4].include?(quarter)
          raise ArgumentError, "bad date format: #{spec}"
        end
        month = quarter * 3
        if spec_type == :from
          ::Date.new(year, month, 1).beginning_of_quarter
        else
          ::Date.new(year, month, 1).end_of_quarter
        end
      when /^([1234])[qQ]$/, /^[qQ]([1234])$/
        # Quarter only
        this_year = today.year
        quarter = $1.to_i
        date = ::Date.new(this_year, quarter * 3, 15)
        if spec_type == :from
          date.beginning_of_quarter
        else
          date.end_of_quarter
        end
      when /^(\d\d\d\d)[-\/](\d)[Hh]$/, /^(\d\d\d\d)[-\/][Hh](\d)$/
        # Year-Half
        year = $1.to_i
        half = $2.to_i
        unless [1, 2].include?(half)
          raise ArgumentError, "bad date format: #{spec}"
        end
        month = half * 6
        if spec_type == :from
          ::Date.new(year, month, 15).beginning_of_half
        else
          ::Date.new(year, month, 1).end_of_half
        end
      when /^([12])[hH]$/, /^[hH]([12])$/
        # Half only
        this_year = today.year
        half = $1.to_i
        date = ::Date.new(this_year, half * 6, 15)
        if spec_type == :from
          date.beginning_of_half
        else
          date.end_of_half
        end
      when /^(\d\d\d\d)[-\/](\d\d?)*$/
        # Year-Month only
        if spec_type == :from
          ::Date.new($1.to_i, $2.to_i, 1)
        else
          ::Date.new($1.to_i, $2.to_i, 1).end_of_month
        end
      when /^(\d\d?)[-\/](\d\d?)*$/
        # Month-Day only
        if spec_type == :from
          ::Date.new(today.year, $1.to_i, $2.to_i)
        else
          ::Date.new(today.year, $1.to_i, $2.to_i).end_of_month
        end
      when /\A(\d\d?)\z/
        # Month only
        if spec_type == :from
          ::Date.new(today.year, $1.to_i, 1)
        else
          ::Date.new(today.year, $1.to_i, 1).end_of_month
        end
      when /^(\d\d\d\d)$/
        # Year only
        if spec_type == :from
          ::Date.new($1.to_i, 1, 1)
        else
          ::Date.new($1.to_i, 12, 31)
        end
      when /^(to|this_?)?day/
        today
      when /^(yester|last_?)?day/
        today - 1.day
      when /^(this_?)?week/
        spec_type == :from ? today.beginning_of_week : today.end_of_week
      when /last_?week/
        if spec_type == :from
          (today - 1.week).beginning_of_week
        else
          (today - 1.week).end_of_week
        end
      when /^(this_?)?biweek/
        if spec_type == :from
          today.beginning_of_biweek
        else
          today.end_of_biweek
        end
      when /last_?biweek/
        if spec_type == :from
          (today - 2.week).beginning_of_biweek
        else
          (today - 2.week).end_of_biweek
        end
      when /^(this_?)?semimonth/
        spec_type == :from ? today.beginning_of_semimonth : today.end_of_semimonth
      when /^last_?semimonth/
        if spec_type == :from
          (today - 15.days).beginning_of_semimonth
        else
          (today - 15.days).end_of_semimonth
        end
      when /^(this_?)?month/
        if spec_type == :from
          today.beginning_of_month
        else
          today.end_of_month
        end
      when /^last_?month/
        if spec_type == :from
          (today - 1.month).beginning_of_month
        else
          (today - 1.month).end_of_month
        end
      when /^(this_?)?bimonth/
        if spec_type == :from
          today.beginning_of_bimonth
        else
          today.end_of_bimonth
        end
      when /^last_?bimonth/
        if spec_type == :from
          (today - 2.month).beginning_of_bimonth
        else
          (today - 2.month).end_of_bimonth
        end
      when /^(this_?)?quarter/
        if spec_type == :from
          today.beginning_of_quarter
        else
          today.end_of_quarter
        end
      when /^last_?quarter/
        if spec_type == :from
          (today - 3.months).beginning_of_quarter
        else
          (today - 3.months).end_of_quarter
        end
      when /^(this_?)?half/
        if spec_type == :from
          today.beginning_of_half
        else
          today.end_of_half
        end
      when /^last_?half/
        if spec_type == :from
          (today - 6.months).beginning_of_half
        else
          (today - 6.months).end_of_half
        end
      when /^(this_?)?year/
        if spec_type == :from
          today.beginning_of_year
        else
          today.end_of_year
        end
      when /^last_?year/
        if spec_type == :from
          (today - 1.year).beginning_of_year
        else
          (today - 1.year).end_of_year
        end
      when /^forever/
        if spec_type == :from
          ::Date::BOT
        else
          ::Date::EOT
        end
      when /^never/
        nil
      else
        raise ArgumentError, "bad date spec: '#{spec}''"
      end
    end

    # @group Utilities

    COMMON_YEAR_DAYS_IN_MONTH = [31, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31,
                                 30, 31].freeze
    def days_in_month(y, m)
      raise ArgumentError, 'illegal month number' if m < 1 || m > 12
      days = COMMON_YEAR_DAYS_IN_MONTH[m]
      if m == 2
        ::Date.new(y, m, 1).leap? ? 29 : 28
      else
        days
      end
    end

    def nth_wday_in_year_month(n, wday, year, month)
      # Return the nth weekday in the given month
      # If n is negative, count from last day of month
      wday = wday.to_i
      raise ArgumentError, 'illegal weekday number' if wday < 0 || wday > 6
      month = month.to_i
      raise ArgumentError, 'illegal month number' if month < 1 || month > 12
      n = n.to_i
      if n.positive?
        # Set d to the 1st wday in month
        d = ::Date.new(year, month, 1)
        d += 1 while d.wday != wday
        # Set d to the nth wday in month
        nd = 1
        while nd != n
          d += 7
          nd += 1
        end
        d
      elsif n.negative?
        n = -n
        # Set d to the last wday in month
        d = ::Date.new(year, month, 1).end_of_month
        d -= 1 while d.wday != wday
        # Set d to the nth wday in month
        nd = 1
        while nd != n
          d -= 7
          nd += 1
        end
        d
      else
        raise ArgumentError,
              'Arg 1 to nth_wday_in_month_year cannot be zero'
      end
    end

    def easter(year)
      y = year
      a = y % 19
      b, c = y.divmod(100)
      d, e = b.divmod(4)
      f = (b + 8) / 25
      g = (b - f + 1) / 3
      h = (19 * a + b - d - g + 15) % 30
      i, k = c.divmod(4)
      l = (32 + 2 * e + 2 * i - h - k) % 7
      m = (a + 11 * h + 22 * l) / 451
      n, p = (h + l - 7 * m + 114).divmod(31)
      Date.new(y, n, p + 1)
    end
  end
end
