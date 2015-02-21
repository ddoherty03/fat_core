# -*- coding: utf-8 -*-

class Period
  include Enumerable
  include Comparable

  attr_reader :first, :last

  def initialize(first, last)
    case first
    when String
      begin
        first = Date.parse(first)
      rescue ArgumentError => ex
        if ex.message =~ /invalid date/
          raise ArgumentError, "you gave an invalid date '#{first}'"
        else
          raise
        end
      end
    when Date
      first = first
    else
      raise ArgumentError, "use Date or String to initialize Period"
    end

    case last
    when String
      begin
        last = Date.parse(last)
      rescue ArgumentError => ex
        if ex.message =~ /invalid date/
          raise ArgumentError, "you gave an invalid date '#{last}'"
        else
          raise
        end
      end
    when Date
      last = last
    else
      raise ArgumentError, "use Date or String to initialize Period"
    end

    @first = first
    @last = last
    if @first > @last
      raise ArgumentError, "Period's first date is later than its last date"
    end
  end

  # These need to come after initialize is defined
  TO_DATE = Period.new(Date::BOT, Date.current)
  FOREVER = Period.new(Date::BOT, Date::EOT)

  # Need custom setters to ensure first <= last
  def first=(new_first)
    unless new_first.kind_of?(Date)
      raise ArgumentError, "can't set Period#first to non-date"
    end
    unless new_first <= last
      raise ArgumentError, "cannot make Period#first > Period#last"
    end
    @first = new_first
  end

  def last=(new_last)
    unless new_last.kind_of?(Date)
      raise ArgumentError, "can't set Period#last to non-date"
    end
    unless new_last >= first
      raise ArgumentError, "cannot make Period#last < Period#first"
    end
    @last = new_last
  end

  # Comparable base: periods are equal only if their first and last dates are
  # equal.  Sorting will be by first date, then last, so periods starting on
  # the same date will sort by last date, thus, from smallest to largest in
  # size.
  def <=>(other)
    [first, size] <=> [other.first, other.size]
  end

  # Comparable does not include this.
  def !=(other)
    !(self == other)
  end

  # Enumerable base.  Yield each day in the period.
  def each
    d = first
    while d <= last
      yield d
      d = d + 1.day
    end
  end

  # Case equality checks for inclusion of date in period.
  def ===(date)
    self.contains?(date)
  end

  def trading_days
    select(&:nyse_workday?)
  end

  # Return a period based on two date specs (see Date.parse_spec), a '''from'
  # and a 'to' spec.  If the to-spec is not given or is nil, the from-spec is
  # used for both the from- and to-spec.  If no from-spec is given, return
  # today as the period.
  def self.parse_spec(from = 'today', to = nil)
    to ||= from
    from ||= to
    Period.new(Date.parse_spec(from, :from), Date.parse_spec(to, :to))
  end

  # Possibly useful class method to take an array of periods and join all the
  # contiguous ones, then return an array of the disjoint periods not
  # contiguous to one another.  An array of periods with no gaps should return
  # an array of only one period spanning all the given periods.

  # Return an array of periods that represent the concatenation of all
  # adjacent periods in the given periods.
  # def self.meld_periods(*periods)
  #   melded_periods = []
  #   while (this_period = periods.pop)
  #     melded_periods.each do |mp|
  #       if mp.overlaps?(this_period)
  #         melded_periods.delete(mp)
  #         melded_periods << mp.union(this_period)
  #         break
  #       elsif mp.contiguous?(this_period)
  #         melded_periods.delete(mp)
  #         melded_periods << mp.join(this_period)
  #         break
  #       end
  #     end
  #   end
  #   melded_periods
  # end

  def self.chunk_syms
    [:day, :week, :biweek, :semimonth, :month, :bimonth,
     :quarter, :year, :irregular]
  end

  def self.chunk_sym_to_days(sym)
    case sym
    when :day
      1
    when :week
      7
    when :biweek
      14
    when :semimonth
      15
    when :month
      30
    when :bimonth
      60
    when :quarter
      90
    when :year
      365
    when :irregular
      30
    else
      raise ArgumentError, "unknown chunk sym '#{sym}'"
    end
  end

  # The largest number of days possible in each chunk
  def self.chunk_sym_to_max_days(sym)
    case sym
    when :semimonth
      16
    when :month
      31
    when :bimonth
      62
    when :quarter
      92
    when :year
      366
    when :irregular
      raise ArgumentError, "no maximum period for :irregular chunk"
    else
      chunk_sym_to_days(sym)
    end
  end

  # This is only used for inferring statement frequency based on the
  # number of days between statements, so it will not consider all
  # possible chunks, only :year, :quarter, :month, and :week.  And
  # distinguishing between :semimonth and :biweek is impossible in
  # some cases since a :semimonth can be 14 days just like a :biweek.
  # This ignores that possiblity and requires a :semimonth to be at
  # least 15 days.
  def self.days_to_chunk_sym(days)
    case days
    when 356..376
      :year
    when 86..96
      :quarter
    when 59..62
      :bimonth
    when 26..33
      :month
    when 15..16
      :semimonth
    when 14
      :biweek
    when 7
      :week
    when 1
      :day
    else
      :irregular
    end
  end

  def to_range
    (first..last)
  end

  def to_s
    if first.beginning_of_year? && last.end_of_year? && first.year == last.year
      "#{first.year}"
    elsif first.beginning_of_quarter? &&
        last.end_of_quarter? &&
        first.year == last.year &&
        first.quarter == last.quarter
      "#{first.year}-#{first.quarter}Q"
    elsif first.beginning_of_month? &&
        last.end_of_month? &&
        first.year == last.year &&
        first.month == last.month
      "#{first.year}-%02d" % first.month
    else
      "#{first.iso} to #{last.iso}"
    end
  end

  # Allow erb documents can directly interpolate ranges
  def tex_quote
    "#{first.iso}--#{last.iso}"
  end

  # Days in period
  def size
    (last - first + 1).to_i
  end

  def length
    size
  end

  def subset_of?(other)
    to_range.subset_of?(other.to_range)
  end

  def proper_subset_of?(other)
    to_range.proper_subset_of?(other.to_range)
  end

  def superset_of?(other)
    to_range.superset_of?(other.to_range)
  end

  def proper_superset_of?(other)
    to_range.proper_superset_of?(other.to_range)
  end

  def overlaps?(other)
    self.to_range.overlaps?(other.to_range)
  end

  def intersection(other)
    result = self.to_range.intersection(other.to_range)
    if result.nil?
      nil
    else
      Period.new(result.first, result.last)
    end
  end
  alias_method :&, :intersection
  alias_method :narrow_to, :intersection

  def union(other)
    result = self.to_range.union(other.to_range)
    Period.new(result.first, result.last)
  end
  alias_method :+, :union

  def difference(other)
    ranges = self.to_range.difference(other.to_range)
    ranges.each.map{ |r| Period.new(r.first, r.last) }
  end
  alias_method :-, :difference

  # returns the chunk sym represented by the period
  def chunk_sym
    if first.beginning_of_year? && last.end_of_year? &&
        (365..366) === last - first + 1
      :year
    elsif first.beginning_of_quarter? && last.end_of_quarter? &&
        (90..92) === last - first + 1
      :quarter
    elsif first.beginning_of_bimonth? && last.end_of_bimonth? &&
        (58..62) === last - first + 1
      :bimonth
    elsif first.beginning_of_month? && last.end_of_month? &&
        (28..31) === last - first + 1
      :month
    elsif first.beginning_of_semimonth? && last.end_of_semimonth &&
        (13..16) === last - first + 1
      :semimonth
    elsif first.beginning_of_biweek? && last.end_of_biweek? &&
        last - first + 1 == 14
      :biweek
    elsif first.beginning_of_week? && last.end_of_week? &&
        last - first + 1 == 7
      :week
    elsif first == last
      :day
    else
      :irregular
    end
  end

  # Name for a period not necessarily ending on calendar boundaries.  For
  # example, in reporting reconciliation, we want the period from Feb 11,
  # 2014, to March 10, 2014, be called the 'Month ending March 10, 2014,'
  # event though the period is not a calendar month.  Using the stricter
  # Period#chunk_sym, would not allow such looseness.
  def chunk_name
    case Period.days_to_chunk_sym(length)
    when :year
      'Year'
    when :quarter
      'Quarter'
    when :bimonth
      'Bi-month'
    when :month
      'Month'
    when :semimonth
      'Semi-month'
    when :biweek
      'Bi-week'
    when :week
      'Week'
    when :day
      'Day'
    else
      'Period'
    end
  end

  def contains?(date)
    if date.respond_to?(:to_date)
      date = date.to_date
    end
    unless (date.is_a? Date)
      raise ArgumentError, "argument must be a Date"
    end
    self.to_range.cover?(date)
  end

  def overlaps?(other)
    self.to_range.overlaps?(other.to_range)
  end

  # Return whether any of the Periods that are within self overlap one
  # another
  def has_overlaps_within?(periods)
    self.to_range.has_overlaps_within?(periods.map{ |p| p.to_range})
  end

  def spanned_by?(periods)
    to_range.spanned_by?(periods.map { |p| p.to_range })
  end

  def gaps(periods)
    to_range.gaps(periods.map { |p| p.to_range }).
      map { |r| Period.new(r.first, r.last)}
  end

  # Return an array of Periods wholly-contained within self in chunks of
  # size, defaulting to monthly chunks.  Partial chunks at the beginning and
  # end of self are not included unless partial_first or partial_last,
  # respectively, are set true.  The last chunk can be made to extend beyond
  # the end of self to make it a whole chunk if round_up_last is set true,
  # in which case, partial_last is ignored.
  def chunks(size: :month, partial_first: false, partial_last: false, round_up_last: false)
    size = size.to_sym
    result = []
    chunk_start = first.dup
    while chunk_start <= last
      case size
      when :year
        unless partial_first
          until chunk_start.beginning_of_year?
            chunk_start += 1.day
          end
        end
        chunk_end = chunk_start.end_of_year
      when :quarter
        unless partial_first
          until chunk_start.beginning_of_quarter?
            chunk_start += 1.day
          end
        end
        chunk_end = chunk_start.end_of_quarter
      when :bimonth
        unless partial_first
          until chunk_start.beginning_of_bimonth?
            chunk_start += 1.day
          end
        end
        chunk_end = (chunk_start.end_of_month + 1.day).end_of_month
      when :month
        unless partial_first
          until chunk_start.beginning_of_month?
            chunk_start += 1.day
          end
        end
        chunk_end = chunk_start.end_of_month
      when :semimonth
        unless partial_first
          until chunk_start.beginning_of_semimonth?
            chunk_start += 1.day
          end
        end
        chunk_end = chunk_start.end_of_semimonth
      when :biweek
        unless partial_first
          until chunk_start.beginning_of_biweek?
            chunk_start += 1.day
          end
        end
        chunk_end = chunk_start.end_of_biweek
      when :week
        unless partial_first
          until chunk_start.beginning_of_week?
            chunk_start += 1.day
          end
        end
        chunk_end = chunk_start.end_of_week
      when :day
        chunk_end = chunk_start
      else
        chunk_end = last
      end
      if chunk_end <= last
        result << Period.new(chunk_start, chunk_end)
      else
        if round_up_last
          result << Period.new(chunk_start, chunk_end)
        elsif partial_last
          result << Period.new(chunk_start, last)
        else
          break
        end
      end
      chunk_start = result.last.last + 1.day
    end
    result
  end
end
