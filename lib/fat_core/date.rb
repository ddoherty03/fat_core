
class Date
  # Constants for Begining of Time (BOT) and End of Time (EOT)
  # Both outside the range of what we would find in an accounting app.
  BOT = Date.parse('1900-01-01')
  EOT = Date.parse('3000-12-31')

  # Convert a string with an American style date into a Date object
  #
  # An American style date is of the form MM/DD/YYYY, that is it places the
  # month first, then the day of the month, and finally the year.  The
  # European convention is to place the day of the month first, DD/MM/YYYY.
  # Because a date found in the wild can be ambiguous, e.g. 3/5/2014, a date
  # string known to be using the American convention can be parsed using this
  # method.  Both the month and the day can be a single digit.  The year can
  # be either 2 or 4 digits, and if given as 2 digits, it adds 2000 to it to
  # give the year.
  #
  # @example
  #     Date.parse_american('9/11/2001') #=> Date(2011, 9, 11)
  #     Date.parse_american('9/11/01')   #=> Date(2011, 9, 11)
  #     Date.parse_american('9/11/1')    #=> ArgumentError
  #
  # @param str [#to_s] a stringling of the form MM/DD/YYYY
  # @return [Date] the date represented by the string paramenter.
  def self.parse_american(str)
    if str.to_s =~ %r{\A\s*(\d\d?)\s*/\s*(\d\d?)\s*/\s*(\d?\d?\d\d)\s*\z}
      year, month, day = $3.to_i, $1.to_i, $2.to_i
      if year < 100
        year += 2000
      end
      Date.new(year, month, day)
    else
      raise ArgumentError, "date string must be of form 'MM?/DD?/YY(YY)?'"
    end
  end

=begin
  Convert a 'date spec' to a Date.  A date spec is a short-hand way of
  specifying a date, relative to the computer clock.  A date spec can
  interpreted as either a 'from spec' or a 'to spec'.

  @example
  Assuming that Date.current at the time of execution is 2014-07-26 and
  using the default spec_type of :from.  The return values are actually Date
  objects, but are shown below as textual dates.

  A fully specified date returns that date:
      Date.parse_spec('2001-09-11')  # =>

  Commercial weeks can be specified using, for example W32 or 32W, with the
  week beginning on Monday, ending on Sunday.
      Date.parse_spec('2012-W32')    # =>
      Date.parse_spec('2012-W32', :to) # =>
      Date.parse_spec('W32') # =>

  A spec of the form Q3 or 3Q returns the beginning or end of calendar
  quarters.
      Date.parse_spec('Q3')         # =>

  @param spec [#to_s] a stringling containing the spec to be interpreted
  @param spec_type [:from, :to] interpret the spec as a from- or to-spec
    respectively, defaulting to interpretation as a to-spec.
  @return [Date] a date object equivalent to the date spec
=end
  def self.parse_spec(spec, spec_type = :from)
    spec = spec.to_s.strip
    unless [:from, :to].include?(spec_type)
      raise ArgumentError "invalid date spec type: '#{spec_type}'"
    end

    today = Date.current
    case spec
    when /^(\d\d\d\d)-(\d\d?)-(\d\d?)*$/
      # A specified date
      Date.new($1.to_i, $2.to_i, $3.to_i)
    when /\AW(\d\d?)\z/, /\A(\d\d?)W\z/
      week_num = $1.to_i
      if week_num < 1 || week_num > 53
        raise ArgumentError, "invalid week number (1-53): 'W#{week_num}'"
      end
      spec_type == :from ? Date.commercial(today.year, week_num).beginning_of_week :
        Date.commercial(today.year, week_num).end_of_week
    when /\A(\d\d\d\d)-W(\d\d?)\z/, /\A(\d\d\d\d)-(\d\d?)W\z/
      year = $1.to_i
      week_num = $2.to_i
      if week_num < 1 || week_num > 53
        raise ArgumentError, "invalid week number (1-53): 'W#{week_num}'"
      end
      spec_type == :from ? Date.commercial(year, week_num).beginning_of_week :
        Date.commercial(year, week_num).end_of_week
    when /^(\d\d\d\d)-(\d)[Qq]$/, /^(\d\d\d\d)-[Qq](\d)$/
      # Year-Quarter
      year = $1.to_i
      quarter = $2.to_i
      unless [1, 2, 3, 4].include?(quarter)
        raise ArgumentError, "bad date format: #{spec}"
      end
      month = quarter * 3
      spec_type == :from ? Date.new(year, month, 1).beginning_of_quarter :
        Date.new(year, month, 1).end_of_quarter
    when /^([1234])[qQ]$/, /^[qQ]([1234])$/
      # Quarter only
      this_year = today.year
      quarter = $1.to_i
      date = Date.new(this_year, quarter * 3, 15)
      spec_type == :from ? date.beginning_of_quarter : date.end_of_quarter
    when /^(\d\d\d\d)-(\d\d?)*$/
      # Year-Month only
      spec_type == :from ? Date.new($1.to_i, $2.to_i, 1) :
        Date.new($1.to_i, $2.to_i, 1).end_of_month
    when /\A(\d\d?)\z/
      # Month only
      spec_type == :from ? Date.new(today.year, $1.to_i, 1) :
        Date.new(today.year, $1.to_i, 1).end_of_month
    when /^(\d\d\d\d)$/
      # Year only
      spec_type == :from ? Date.new($1.to_i, 1, 1) : Date.new($1.to_i, 12, 31)
    when /^(to|this_?)?day/
      today
    when /^(yester|last_?)?day/
      today - 1.day
    when /^(this_?)?week/
      spec_type == :from ? today.beginning_of_week : today.end_of_week
    when /last_?week/
      spec_type == :from ? (today - 1.week).beginning_of_week :
        (today - 1.week).end_of_week
    when /^(this_?)?biweek/
      spec_type == :from ? today.beginning_of_biweek : today.end_of_biweek
    when /last_?biweek/
      spec_type == :from ? (today - 2.week).beginning_of_biweek :
        (today - 2.week).end_of_biweek
    when /^(this_?)?semimonth/
      spec_type == :from ? today.beginning_of_semimonth : today.end_of_semimonth
    when /^last_?semimonth/
      spec_type == :from ? (today - 15.days).beginning_of_semimonth :
        (today - 15.days).end_of_semimonth
    when /^(this_?)?month/
      spec_type == :from ? today.beginning_of_month : today.end_of_month
    when /^last_?month/
      spec_type == :from ? (today - 1.month).beginning_of_month :
        (today - 1.month).end_of_month
    when /^(this_?)?bimonth/
      spec_type == :from ? today.beginning_of_bimonth : today.end_of_bimonth
    when /^last_?bimonth/
      spec_type == :from ? (today - 2.month).beginning_of_bimonth :
        (today - 2.month).end_of_bimonth
    when /^(this_?)?quarter/
      spec_type == :from ? today.beginning_of_quarter : today.end_of_quarter
    when /^last_?quarter/
      spec_type == :from ? (today - 3.months).beginning_of_quarter :
        (today - 3.months).end_of_quarter
    when /^(this_?)?year/
      spec_type == :from ? today.beginning_of_year : today.end_of_year
    when /^last_?year/
      spec_type == :from ? (today - 1.year).beginning_of_year :
        (today - 1.year).end_of_year
    when /^forever/
      spec_type == :from ? Date::BOT : Date::EOT
    when /^never/
      nil
    else
      raise ArgumentError, "bad date spec: '#{spec}''"
    end # !> previous definition of length was here
  end

  # Predecessor of self.  Allows Date to work as a countable element
  # of a Range.
  def pred
    self - 1.day
  end

  # Successor of self.  Allows Date to work as a countable element
  # of a Range.
  def succ
    self + 1.day
  end

  # Format as an ISO string.
  def iso
    strftime("%Y-%m-%d")
  end

  # Format date to TeX documents as ISO strings
  def tex_quote
    iso
  end

  # Format as an all-numeric string, i.e. 'YYYYMMDD'
  def num
    strftime("%Y%m%d")
  end

  # Format as an inactive Org date (see emacs org-mode)
  def org
    strftime("[%Y-%m-%d %a]")
  end

  # Format as an English string
  def eng
    strftime("%B %e, %Y")
  end

  # Format date in MM/DD/YYYY form, as typical for the short American
  # form.
  def american
    strftime "%-m/%-d/%Y"
  end

  # Does self fall on a weekend?
  def weekend?
    saturday? || sunday?
  end

  # Does self fall on a weekday?
  def weekday?
    !weekend?
  end

  # Self's calendar quarter: 1, 2, 3, or 4
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

  # The date that is the first day of the bimonth in which self
  # falls. A 'bimonth' is a two-month calendar period beginning on the
  # first day of the odd-numbered months.  E.g., 2014-01-01 to
  # 2014-02-28 is the first bimonth of 2014.
  def beginning_of_bimonth
    if month % 2 == 1
      beginning_of_month
    else
      (self - 1.month).beginning_of_month
    end
  end

  # The date that is the last day of the bimonth in which self falls.
  # A 'bimonth' is a two-month calendar period beginning on the first
  # day of the odd-numbered months.  E.g., 2014-01-01 to 2014-02-28 is
  # the first bimonth of 2014.
  def end_of_bimonth
    if month % 2 == 1
      (self + 1.month).end_of_month
    else
      end_of_month
    end
  end

  # The date that is the first day of the semimonth in which self
  # falls.  A semimonth is a calendar period beginning on the 1st or
  # 16th of each month and ending on the 15th or last day of the month
  # respectively.  So each year has exactly 24 semimonths.
  def beginning_of_semimonth
    if day >= 16
      Date.new(year, month, 16)
    else
      beginning_of_month
    end
  end

  # The date that is the last day of the semimonth in which self
  # falls.  A semimonth is a calendar period beginning on the 1st or
  # 16th of each month and ending on the 15th or last day of the month
  # respectively.  So each year has exactly 24 semimonths.
  def end_of_semimonth
    if day <= 15
      Date.new(year, month, 15)
    else
      end_of_month
    end
  end

  # Note: we use a Monday start of the week in the next two methods because
  # commercial week counting assumes a Monday start.
  def beginning_of_biweek
    if cweek % 2 == 1
      beginning_of_week(:monday)
    else
      (self - 1.week).beginning_of_week(:monday)
    end
  end

  def end_of_biweek
    if cweek % 2 == 1
      (self + 1.week).end_of_week(:monday)
    else
      end_of_week(:monday)
    end
  end

  def beginning_of_year?
    beginning_of_year == self
  end

  def end_of_year?
    end_of_year == self
  end

  def beginning_of_quarter?
    beginning_of_quarter == self
  end

  def end_of_quarter?
    end_of_quarter == self
  end

  def beginning_of_bimonth?
    month % 2 == 1 &&
      beginning_of_month == self
  end

  def end_of_bimonth?
    month % 2 == 0 &&
      end_of_month == self
  end

  def beginning_of_month?
    beginning_of_month == self
  end

  def end_of_month?
    end_of_month == self
  end

  def beginning_of_semimonth?
    beginning_of_semimonth == self
  end

  def end_of_semimonth?
    end_of_semimonth == self
  end

  def beginning_of_biweek?
    beginning_of_biweek == self
  end

  def end_of_biweek?
    end_of_biweek == self
  end

  def beginning_of_week?
    beginning_of_week == self
  end

  def end_of_week?
    end_of_week == self
  end

  def expand_to_period(sym)
    require 'fat_core/period'
    Period.new(beginning_of_chunk(sym), end_of_chunk(sym))
  end

  def add_chunk(chunk)
    case chunk
    when :year
      next_year
    when :quarter
      next_month(3)
    when :bimonth
      next_month(2)
    when :month
      next_month
    when :semimonth
      self + 15.days
    when :biweek
      self + 14.days
    when :week
      self + 7.days
    when :day
      self + 1.days
    else
      raise ArgumentError, "add_chunk unknown chunk: '#{chunk}'"
    end
  end

  def beginning_of_chunk(sym)
    case sym
    when :year
      beginning_of_year
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
      raise ArgumentError, "unknown chunk sym: '#{sym}'"
    end
  end

  def end_of_chunk(sym)
    case sym
    when :year
      end_of_year
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
      raise LogicError, "unknown chunk sym: '#{sym}'"
    end
  end

  # Holidays decreed by executive order
  # See http://www.whitehouse.gov/the-press-office/2012/12/21/
  #  executive-order-closing-executive-departments-and-agencies-federal-gover
  FED_DECREED_HOLIDAYS =
    [
     Date.parse('2012-12-24')
    ]

  def self.days_in_month(y, m)
    if m < 1 || m > 12
      raise ArgumentError, "illegal month number"
    end
    days = Time::COMMON_YEAR_DAYS_IN_MONTH[m]
    if m == 2
      Date.new(y, m, 1).leap? ? 29 : 28
    else
      days
    end
  end

  def self.nth_wday_in_year_month(n, wday, year, month)
    # Return the nth weekday in the given month
    # If n is negative, count from last day of month
    wday = wday.to_i
    if wday < 0 || wday > 6
      raise ArgumentError, "illegal weekday number"
    end
    month = month.to_i
    if month < 1 || month > 12
      raise ArgumentError, "illegal month number"
    end
    n = n.to_i
    if n > 0
      # Set d to the 1st wday in month
      d = Date.new(year, month, 1)
      while d.wday != wday
        d += 1
      end
      # Set d to the nth wday in month
      nd = 1
      while nd != n
        d += 7
        nd += 1
      end
      d
    elsif n < 0
      n = -n
      # Set d to the last wday in month
      d = Date.new(year, month, 1).end_of_month
      while d.wday != wday;
        d -= 1
      end
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

  def within_6mos_of?(d)
    # Date 6 calendar months before self
    start_date = self - 6.months + 2.days
    end_date = self + 6.months - 2.days
    (start_date..end_date).cover?(d)
  end

  def self.easter(year)
    y = year
    a = y % 19
    b, c = y.divmod(100)
    d, e = b.divmod(4)
    f = (b + 8) / 25
    g = (b - f + 1) / 3
    h = (19 * a + b - d - g + 15) % 30
    i, k = c.divmod(4)
    l = (32 + 2*e + 2*i - h - k) % 7
    m = (a + 11*h + 22*l) / 451
    n, p = (h + l - 7*m + 114).divmod(31)
    Date.new(y, n, p + 1)
   end

  def easter_this_year
    # Return the date of Easter in self's year
    Date.easter(year)
  end

  def easter?
    # Am I Easter?
    self == easter_this_year
  end

  def nth_wday_in_month?(n, wday, month)
    # Is self the nth weekday in the given month of its year?
    # If n is negative, count from last day of month
    self == Date.nth_wday_in_year_month(n, wday, self.year, month)
  end

  #######################################################
  # Calculations for Federal holidays
  # 5 USC 6103
  #######################################################
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
    if [ 3, 4, 6, 7, 8, 12 ].include?(month)
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

  def fed_holiday?
    # All Saturdays and Sundays are "holidays"
    return true if weekend?

    # Some days are holidays by executive decree
    return true if FED_DECREED_HOLIDAYS.include?(self)

    # Is self a fixed holiday
    return true if (fed_fixed_holiday? || fed_moveable_feast?)

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

  #######################################################
  # Calculations for NYSE holidays
  # Rule 51 and supplementary material
  #######################################################

  # Rule: if it falls on Saturday, observe on preceding Friday.
  # Rule: if it falls on Sunday, observe on following Monday.
  #
  # New Year's Day, January 1.
  # Birthday of Martin Luther King, Jr., the third Monday in January.
  # Washington's Birthday, the third Monday in February.
  # Good Friday Friday before Easter Sunday.  NOTE: not a fed holiday
  # Memorial Day, the last Monday in May.
  # Independence Day, July 4.
  # Labor Day, the first Monday in September.
  # NOTE: Columbus and Veterans days not observed
  # Thanksgiving Day, the fourth Thursday in November.
  # Christmas Day, December 25.

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

  def nyse_moveable_feast?
    # See if today is a "movable feast," all of which are
    # rigged to fall on Monday except Thanksgiving

    # No moveable feasts in certain months
    return false if [ 6, 7, 8, 10, 12 ].include?(month)

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
      else
        # Good Friday, the Friday before Easter, except certain years
        if [1898, 1906, 1907].include?(year)
          false
        else
          (self + 2).easter?
        end
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
        first_tuesday = Date.nth_wday_in_year_month(1, 1, year, 11) + 1
        is_election_day = (self == first_tuesday)
        if year <= 1968
          is_election_day
        elsif year <= 1980
          is_election_day && (year % 4 == 0)
        else
          false
        end
      elsif thursday?
        # Historically Thanksgiving (NYSE closed all day) had been declared to be
        #   the last Thursday in November until 1938;
        #   the next-to-last Thursday in November from 1939 to 1941
        #     (therefore the 3rd Thursday in 1940 and 1941);
        #   the last Thursday in November in 1942;
        #   the fourth Thursday in November since 1943;
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

  # They NYSE has closed on several occasions outside its normal holiday
  # rules.  This detects those dates beginning in 1960.  Closing for part of a
  # day is not counted. See http://www1.nyse.com/pdfs/closings.pdf
  def nyse_special_holiday
    return false unless self > Date.parse('1960-01-01')
    case self
    when Date.parse('1961-05-29')
      # Day before Decoaration Day
      true
    when Date.parse('1963-11-25')
      # President Kennedy's funeral
      true
    when Date.parse('1965-12-24')
      # Christmas eve unscheduled for normal holiday
      true
    when Date.parse('1968-02-12')
      # Lincoln birthday
      true
    when Date.parse('1968-04-09')
      # Mourning MLK
      true
    when Date.parse('1968-07-05')
      # Day after Independence Day
      true
    when (Date.parse('1968-06-12')..Date.parse('1968-12-31'))
      # Paperwork crisis (closed on Wednesdays if no other holiday in week)
      wednesday? && (self - 2).nyse_workday? && (self - 1).nyse_workday? &&
        (self + 1).nyse_workday? && (self + 2).nyse_workday?
    when Date.parse('1969-02-10')
      # Heavy snow
      true
    when Date.parse('1969-05-31')
      # Eisenhower Funeral
      true
    when Date.parse('1969-07-21')
      # Moon landing
      true
    when Date.parse('1972-12-28')
      # Truman Funeral
      true
    when Date.parse('1973-01-25')
      # Johnson Funeral
      true
    when Date.parse('1977-07-14')
      # Electrical blackout NYC
      true
    when Date.parse('1985-09-27')
      # Hurricane Gloria
      true
    when Date.parse('1994-04-27')
      # Nixon Funeral
      true
    when (Date.parse('2001-09-11')..Date.parse('2001-09-14'))
      # 9-11 Attacks
      true
    when (Date.parse('2004-06-11')..Date.parse('2001-09-14'))
      # Reagan Funeral
      true
    when Date.parse('2007-01-02')
      # Observance death of President Ford
      true
    when Date.parse('2012-10-29'), Date.parse('2012-10-30')
      # Hurricane Sandy
      true
    else
      false
    end
  end

  def nyse_holiday?
    # All Saturdays and Sundays are "holidays"
    return true if weekend?

    # Is self a fixed holiday
    return true if nyse_fixed_holiday? || nyse_moveable_feast?

    return true if nyse_special_holiday

    if friday? && (self >= Date.parse('1959-07-03'))
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

  def fed_workday?
    !fed_holiday?
  end

  def nyse_workday?
    !nyse_holiday?
  end
  alias :trading_day? :nyse_workday?

  def add_fed_business_days(n)
    d = self.dup
    return d if n == 0
    incr = n < 0 ? -1 : 1
    n = n.abs
    while n > 0
      d += incr
      if d.fed_workday?
        n -= 1
      end
     end
    d
  end

  def next_fed_workday
    add_fed_business_days(1)
  end

  def prior_fed_workday
    add_fed_business_days(-1)
  end

  def add_nyse_business_days(n)
    d = self.dup
    return d if n == 0
    incr = n < 0 ? -1 : 1
    n = n.abs
    while n > 0
      d += incr
      if d.nyse_workday?
        n -= 1
      end
     end
    d
  end

  def next_nyse_workday
    add_nyse_business_days(1)
  end
  alias :next_trading_day :next_nyse_workday

  def prior_nyse_workday
    add_nyse_business_days(-1)
  end
  alias :prior_trading_day :prior_nyse_workday
end
