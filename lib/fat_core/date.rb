class Date
  # Constants for Begining of Time (BOT) and End of Time (EOT)
  # Just outside the range of what we would find in an accounting app.
  BOT = Date.parse('1900-01-01')
  EOT = Date.parse('3000-12-31')

  def self.parse_american(str)
    str =~ %r{\A\s*(\d\d?)\s*/\s*(\d\d?)\s*/\s*(\d?\d?\d\d)\s*\z}
    year, month, day = $3.to_i, $1.to_i, $2.to_i
    if year < 100
      year += 2000
    end
    Date.new(year, month, day)
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
    when /\AW(\d\d?)\z/
      week_num = $1.to_i
      if week_num < 1 || week_num > 53
        raise Byr::UserError, "invalid week number (1-53): 'W#{week_num}'"
      end
      spec_type == :from ? Date.commercial(today.year, week_num).beginning_of_week :
        Date.commercial(today.year, week_num).end_of_week
    when /\A(\d\d\d\d)-W(\d\d?)\z/
      year = $1.to_i
      week_num = $2.to_i
      if week_num < 1 || week_num > 53
        raise Byr::UserError, "invalid week number (1-53): 'W#{week_num}'"
      end
      spec_type == :from ? Date.commercial(year, week_num).beginning_of_week :
        Date.commercial(year, week_num).end_of_week
    when /^(\d\d\d\d)-(\d)[Qq]$/
      # Year-Quarter
      year = $1.to_i
      quarter = $2.to_i
      unless [1, 2, 3, 4].include?(quarter)
        raise Byr::UserError, "bad date format: #{spec}"
      end
      month = quarter * 3
      spec_type == :from ? Date.new(year, month, 1).beginning_of_quarter :
        Date.new(year, month, 1).end_of_quarter
    when /^([1234])[qQ]$/
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

  # For lazy date entry, expand missing components of a date from
  # components of the template date form.  Note that the template may
  # be in the form of an org date.
  def self.expand_from_template(partial, template)
    template =~ /\A\s*[\[<]?\s*(\d\d\d\d)\s*-\s*(\d\d?)\s*-\s*(\d\d?)\s*\w*\s*[\]>]?\s*\z/
    year = $1.to_i; month = $2.to_i; day = $3.to_i
    result = nil
    case partial
    when /\A\s*(\d\d?)\s*\z/
      day = $1.to_i
    when /\A\s*(\d\d?)\s*[-\/]\s*(\d\d?)\s*\z/
      month = $1.to_i; day = $2.to_i
    when /\A\s*(\d\d\d\d)\s*[-\/]\s*(\d\d?)\s*[-\/]\s*(\d\d?)\s*\z/
      year = $1.to_i; month = $2.to_i; day = $3.to_i
    when /\A\s*(\d\d?)\s*[-\/]\s*(\d\d?)\s*[-\/]\s*(\d\d\d\d)\s*\z/
      month = $1.to_i; day = $2.to_i; year = $3.to_i
    else
      result = partial
    end
    unless result
      result = "%04d-%02d-%02d" % [year, month, day]
    end
    result
  end

  def pred
    self - 1.day
  end

  def succ
    self + 1.day
  end

  def iso
    return strftime("%Y-%m-%d")
  end

  def org
    return strftime("[%Y-%m-%d %a]")
  end

  def eng
    return strftime("%B %e, %Y")
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

  require 'fat_core/period'
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
end
