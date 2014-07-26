require 'fat_core/period'

class Date
  # Constants for Begining of Time (BOT) and End of Time (EOT)
  # Just outside the range of what we would find in an accounting app.
  BOT = Date.parse('1900-01-01')
  EOT = Date.parse('3000-12-31')

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

  def self.parse_spec(spec, spec_type = :from)
    spec = spec.strip
    unless [:from, :to].include?(spec_type)
      raise Byr::LogicError "invalid date spec type: '#{spec_type}'"
    end

    today = Date.current
    case spec
    when /^(\d\d\d\d)-(\d\d?)-(\d\d?)*$/
      # A specified date
      Date.new($1.to_i, $2.to_i, $3.to_i)
    when /\AW(\d\d?)\z/, /\A(\d\d?)W\z/
      week_num = $1.to_i
      if week_num < 1 || week_num > 53
        raise Byr::UserError, "invalid week number (1-53): 'W#{week_num}'"
      end
      spec_type == :from ? Date.commercial(today.year, week_num).beginning_of_week :
        Date.commercial(today.year, week_num).end_of_week
    when /\A(\d\d\d\d)-W(\d\d?)\z/, /\A(\d\d\d\d)-(\d\d?)W\z/
      year = $1.to_i
      week_num = $2.to_i
      if week_num < 1 || week_num > 53
        raise Byr::UserError, "invalid week number (1-53): 'W#{week_num}'"
      end
      spec_type == :from ? Date.commercial(year, week_num).beginning_of_week :
        Date.commercial(year, week_num).end_of_week
    when /^(\d\d\d\d)-(\d)[Qq]$/, /^(\d\d\d\d)-[Qq](\d)$/
      # Year-Quarter
      year = $1.to_i
      quarter = $2.to_i
      unless [1, 2, 3, 4].include?(quarter)
        raise Byr::UserError, "bad date format: #{spec}"
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
      spec_type == :from ? (today - 1.week).beginning_of_biweek :
        (today - 1.week).end_of_biweek
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
      spec_type == :from ? (today - 1.month).beginning_of_bimonth :
        (today - 1.month).end_of_bimonth
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
      raise Byr::UserError, "bad date spec: '#{spec}''"
    end
  end

  def weekend?
    saturday? || sunday?
  end

  def weekday?
    !weekend?
  end

  def pred
    self - 1.day
  end

  def succ
    self + 1.day
  end

  def iso
    strftime("%Y-%m-%d")
  end

  def org
    strftime("[%Y-%m-%d %a]")
  end

  def eng
    strftime("%B %e, %Y")
  end

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

  def beginning_of_bimonth
    if month % 2 == 1
      beginning_of_month
    else
      (self - 1.month).beginning_of_month
    end
  end

  def end_of_bimonth
    if month % 2 == 1
      (self + 1.month).end_of_month
    else
      end_of_month
    end
  end

  def beginning_of_semimonth
    if day >= 16
      Date.new(year, month, 16)
    else
      beginning_of_month
    end
  end

  def end_of_semimonth
    if day <= 15
      Date.new(year, month, 15)
    else
      end_of_month
    end
  end

  # Note: we use a monday start of the week in the next two methods because
  # commercial week counting assumes a monday start.
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
    self.beginning_of_year == self
  end

  def end_of_year?
    self.end_of_year == self
  end

  def beginning_of_quarter?
    self.beginning_of_quarter == self
  end

  def end_of_quarter?
    self.end_of_quarter == self
  end

  def beginning_of_bimonth?
    month % 2 == 1 &&
      self.beginning_of_month == self
  end

  def end_of_bimonth?
    month % 2 == 0 &&
      self.end_of_month == self
  end

  def beginning_of_month?
    self.beginning_of_month == self
  end

  def end_of_month?
    self.end_of_month == self
  end

  def beginning_of_semimonth?
    self.beginning_of_semimonth == self
  end

  def end_of_semimonth?
    self.end_of_semimonth == self
  end

  def beginning_of_biweek?
    self.beginning_of_biweek == self
  end

  def end_of_biweek?
    self.end_of_biweek == self
  end

  def beginning_of_week?
    self.beginning_of_week == self
  end

  def end_of_week?
    self.end_of_week == self
  end

  # Format date in MM/DD/YYYY form
  def american
    strftime "%-m/%-d/%Y"
  end

  def expand_to_period(sym)
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
      raise LogicError, "add_chunk unknown chunk: '#{chunk}'"
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
      raise LogicError, "unknown chunk sym: '#{sym}'"
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
  FED_DECLARED_HOLIDAYS =
    [
     Date.parse('2012-12-24')
    ]

  def self.days_in_month(y, m)
    days = Time::COMMON_YEAR_DAYS_IN_MONTH[m]
    return(days) unless m == 2
    return Date.new(y, m, 1).leap? ? 29 : 28
  end

  def self.nth_wday_in_year_month(n, wday, year, month)
    # Return the nth weekday in the given month
    # If n is negative, count from last day of month
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
      return d
    elsif n < 0
      n = -n
      # Set d to the last wday in month
      d = Date.new(year, month,
                   Date.last_day_in_year_month(year, month))
      while d.wday != wday;
        d -= 1
      end
      # Set d to the nth wday in month
      nd = 1
      while nd != n
        d -= 7
        nd += 1
      end
      return d
    else
      raise ArgumentError,
        'Arg 1 to nth_wday_in_month_year cannot be zero'
    end
  end

  def self.last_day_in_year_month(year, month)
    days = [
            31, # Dec
            31, # Jan
            28, # Feb
            31, # Mar
            30, # Apr
            31, # May
            30, # Jun
            31, # Jul
            31, # Aug
            30, # Sep
            31, # Oct
            30, # Nov
            31, # Dec
           ]
    days[2] = 29 if Date.new(year, month, 1).leap?
    days[month % 12]
  end

  def easter_this_year
    # Return the date of Easter in self's year
    y = self.year
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
    return Date.new(y, n, p + 1)
  end

  def easter?
    # Am I Easter?
    # Easter is always in March or April
    return false unless [3, 4].include?(self.mon)
    return self == self.easter_this_year
  end

  def nth_wday_in_month?(n, wday, month)
    # Is self the nth weekday in the given month of its year?
    # If n is negative, count from last day of month
    if self.wday != wday
      return false
    elsif self.mon != month
      return false
    else
      return self == Date.nth_wday_in_year_month(n, wday, self.year, month)
    end
  end

  def fed_fixed_holiday?
    # Fixed-date holidays on weekdays
    if self.mon == 1 && self.mday == 1
      # New Years (January 1),
      return true
    elsif self.mon == 7 && self.mday == 4
      # Independence Day (July 4),
      return true
    elsif self.mon == 11 && self.mday == 11
      # Veterans Day (November 11),
      return true
    elsif self.mon == 12 && self.mday == 25
      # Christmas (December 25), and
      return true
    elsif self.mon == 12 && self.mday == 31
      # New Year's Eve (December 31)
      return true;
    else
      return false
    end
  end

  def fed_moveable_feast?
    # See if today is a "movable feast," all of which are
    # rigged to fall on Monday except Thanksgiving

    # No moveable feasts in certain months
    if [ 3, 4, 6, 7, 8, 12 ].include?(self.month)
      return false
    elsif self.wday == 1
      # MLK's Birthday (Third Monday in Jan)
      return true if self.nth_wday_in_month?(3, 1, 1)
      # Washington's Birthday (Third Monday in Feb)
      return true if self.nth_wday_in_month?(3, 1, 2)
      # Memorial Day (Last Monday in May)
      return true if self.nth_wday_in_month?(-1, 1, 5)
      # Labor Day (First Monday in Sep)
      return true if self.nth_wday_in_month?(1, 1, 9)
      # Columbus Day (Second Monday in Oct)
      return true if self.nth_wday_in_month?(2, 1, 10)
      # Other Mondays
      return false
    elsif self.wday == 4
      # Thanksgiving Day (Fourth Thur in Nov)
      return false unless self.month == 11
      return self.nth_wday_in_month?(4, 4, 11)
    else
      return false
    end
  end

  def fed_holiday?
    if FED_DECLARED_HOLIDAYS.include?(self)
      return true
    end

    # All Saturdays and Sundays are "holidays"
    if self.weekend? then return true end

    # Is self a fixed holiday
    return true if self.fed_fixed_holiday?

    # A Friday is a holiday if a fixed-date holiday
    # would fall on the following Saturday
    if self.wday == 5
      td = self + 1
      return true if td.fed_fixed_holiday?
    end

    # A Monday is a holiday if a fixed-date holiday
    # would fall on the preceding Sunday
    if self.wday == 1
      td = self - 1
      return true if td.fed_fixed_holiday?
    end

    # If Christmas falls on a Thursday, apparently, the Friday after is
    # treated as a holiday as well.  See 2003, 2008, for example.
    if self.wday == 5 and self.month == 12 and self.day == 26
      return true
    end

    # It's last chance is if its a movable feast
    return self.fed_moveable_feast?;
  end

  #######################################################
  # Calulations for NYSE holidays
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
    if self.mon == 1 && self.mday == 1
      # New Years (January 1),
      return true
    elsif self.mon == 7 && self.mday == 4
      # Independence Day (July 4),
      return true
    elsif self.mon == 12 && self.mday == 25
      # Christmas (December 25), and
      return true
    else
      return false
    end
  end

  def nyse_moveable_feast?
    # See if today is a "movable feast," all of which are
    # rigged to fall on Monday except Thanksgiving

    # No moveable feasts in certain months
    if [ 6, 7, 8, 10, 12 ].include?(self.month)
      return false
    elsif self.wday == 1
      # MLK's Birthday (Third Monday in Jan)
      return true if self.nth_wday_in_month?(3, 1, 1)
      # Washington's Birthday (Third Monday in Feb)
      return true if self.nth_wday_in_month?(3, 1, 2)
      # Memorial Day (Last Monday in May)
      return true if self.nth_wday_in_month?(-1, 1, 5)
      # Labor Day (First Monday in Sep)
      return true if self.nth_wday_in_month?(1, 1, 9)
      # Other Mondays
      return false
    elsif self.wday == 4
      # Thanksgiving Day (Fourth Thur in Nov)
      return false unless self.month == 11
      return self.nth_wday_in_month?(4, 4, 11)
    elsif self.wday == 5
      # Good Friday, the Friday before Easter
      td = self + 2
      return td.easter?
    else
      return false
    end
  end

  def nyse_holiday?
    # All Saturdays and Sundays are "holidays"
    return true if self.weekend?

    # Is self a fixed holiday
    return true if self.nyse_fixed_holiday?

    # A Friday is a holiday if a fixed-date holiday
    # would fall on the following Saturday
    if self.wday == 5
      td = self + 1
      return true if td.nyse_fixed_holiday?
    end

    # A Monday is a holiday if a fixed-date holiday
    # would fall on the preceding Sunday
    if self.wday == 1
      td = self - 1
      return true if td.nyse_fixed_holiday?
    end

    # It's last chance is if its a movable feast
    return self.nyse_moveable_feast?;
  end

  def fed_workday?
    return ! self.fed_holiday?;
  end

  def nyse_workday?
    return ! self.nyse_holiday?;
  end

  def next_fed_workday
    result = self + 1
    while result.fed_holiday?
      result += 1;
    end
    return result
  end

  def add_fed_business_days(n)
    d = self.dup
    if n < 0
      n.abs.times { d = d.prior_fed_workday }
    elsif n > 0
      n.times { d = d.next_fed_workday }
    end
    d
  end

  def next_nyse_workday
    result = self.dup
    result += 1
    while result.nyse_holiday?
      result += 1;
    end
    return result
  end

  def add_nyse_business_days(n)
    d = self.dup
    if n < 0
      n.abs.times { d = d.prior_nyse_workday }
    elsif n > 0
      n.times { d = d.next_nyse_workday }
    end
    d
  end

  def prior_fed_workday
    result = self - 1
    while result.fed_holiday?
      result -= 1;
    end
    return result
  end

  def prior_nyse_workday
    result = self.dup
    result -= 1
    while result.nyse_holiday?
      result -= 1;
    end
    return result
  end

  def iso
    strftime("%Y-%m-%d")
  end

  def num
    strftime("%Y%m%d")
  end

  def within_6mos_of?(d)
    # Date 6 calendar months before self
    start_date = self - 6.months + 2.days
    end_date = self + 6.months - 2.days
    (start_date..end_date).cover?(d)
  end

  # Allow erb documents can directly interpolate dates
  def tex_quote
    iso
  end
end
