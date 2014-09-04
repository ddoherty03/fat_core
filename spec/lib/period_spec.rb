require 'spec_helper'

describe Period do
  before :each do
    # Pretend it is this date. Not at beg or end of year, quarter,
    # month, or week.  It is a Wednesday
    allow(Date).to receive_messages(:today => Date.parse('2012-07-18'))
    allow(Date).to receive_messages(:current => Date.parse('2012-07-18'))
  end

  describe "initialization" do

    it "should be initializable with date strings" do
      expect(Period.new('2013-01-01', '2013-12-13')).to be_instance_of Period
    end

    it "should be initializable with Dates" do
      expect(Period.new('2013-01-01', '2013-12-13')).
        to be_instance_of Period
    end

    it "should raise a ArgumentError if last > first" do
      expect {
        Period.new('2013-01-01', '2012-12-31')
      }.to raise_error ArgumentError
    end

    it "should raise a ArgumentError if initialized with invalid date string" do
      expect {
        Period.new('2013-01-01', '2013-12-32')
      }.to raise_error ArgumentError
      expect {
        Period.new('2013-13-01', '2013-12-31')
      }.to raise_error ArgumentError
    end

    it "should raise a ArgumentError if initialized otherwise" do
      expect {
        Period.new(2013-01-01, 2013-12-31)
      }.to raise_error ArgumentError
    end
  end

  describe "class methods" do

    it "should know how to parse a pair of date specs" do
      expect(Period.parse_spec.first).to eq Date.current
      expect(Period.parse_spec('2014-3Q').first).to eq Date.parse('2014-07-01')
      expect(Period.parse_spec('2014-3Q').last).to eq Date.parse('2014-09-30')
      expect(Period.parse_spec(nil, '2014-3Q').last).to eq Date.parse('2014-09-30')
    end

    it "should know the days in a chunk sym" do
      expect(Period.chunk_sym_to_days(:year)).to eq(365)
      expect(Period.chunk_sym_to_days(:quarter)).to eq(90)
      expect(Period.chunk_sym_to_days(:bimonth)).to eq(60)
      expect(Period.chunk_sym_to_days(:month)).to eq(30)
      expect(Period.chunk_sym_to_days(:semimonth)).to eq(15)
      expect(Period.chunk_sym_to_days(:biweek)).to eq(14)
      expect(Period.chunk_sym_to_days(:week)).to eq(7)
      expect(Period.chunk_sym_to_days(:day)).to eq(1)
      expect(Period.chunk_sym_to_days(:irregular)).to eq(30)
      expect {
        Period.chunk_sym_to_days(:eon)
      }.to raise_error ArgumentError
    end

    it "should know the chunk sym for given days but only :year, :quarter, :month" do
      (356..376).each { |d| expect(Period.days_to_chunk_sym(d)).to eq(:year) }
      (86..96).each { |d| expect(Period.days_to_chunk_sym(d)).to eq(:quarter) }
      (28..31).each { |d| expect(Period.days_to_chunk_sym(d)).to eq(:month) }
      expect(Period.days_to_chunk_sym(7)).to eq(:week)
      expect(Period.days_to_chunk_sym(1)).to eq(:day)
    end

    it "should know what to call a chunk based on its size" do
      expect(Period.new('2011-01-01', '2011-12-31').chunk_name).to eq('Year')
      expect(Period.new('2011-01-01', '2011-03-31').chunk_name).to eq('Quarter')
      expect(Period.new('2011-01-01', '2011-01-31').chunk_name).to eq('Month')
      expect(Period.new('2011-01-01', '2011-01-07').chunk_name).to eq('Week')
      expect(Period.new('2011-01-01', '2011-01-01').chunk_name).to eq('Day')
      expect(Period.new('2011-01-01', '2011-01-21').chunk_name).to eq('Period')
      # Only size matters, not whether the period begins and ends on
      # calendar unit boundaries.
      expect(Period.new('2011-02-11', '2011-03-10').chunk_name).to eq('Month')
    end
  end

  describe "instance methods" do

    it "should be able to compare for equality" do
      pp1 = Period.new('2013-01-01', '2013-12-31')
      pp2 = Period.new('2013-01-01', '2013-12-31')
      pp3 = Period.new('2013-01-01', '2013-12-30')
      expect((pp1 == pp2)).to be true
      expect((pp1 == pp3)).to_not be true
    end

    it "should be able to convert into a Range" do
      pp = Period.new('2013-01-01', '2013-12-31')
      rr = Period.new('2013-01-01', '2013-12-31').to_range
      expect(rr).to be_instance_of Range
      expect(rr.first).to eq(pp.first)
      expect(rr.last).to eq(pp.last)
    end

    it "should be able to tell if it contains a date" do
      pp = Period.new('2013-01-01', '2013-12-31')
      expect(pp.contains?(Date.parse('2013-01-01'))).to be true
      expect(pp.contains?(Date.parse('2013-07-04'))).to be true
      expect(pp.contains?(Date.parse('2013-12-31'))).to be true
      expect(pp.contains?(Date.parse('2012-07-04'))).to be false
    end

    it "should raise an error if contains? arg is not a date" do
      pp = Period.new('2013-01-01', '2013-12-31')
      expect {
        pp.contains?(Period.new('2013-06-01', '2013-06-30'))
      }.to raise_error(/must be a Date/)

      # But not if argument can be converted to date with to_date
      expect {
        pp.contains?(Time.now)
      }.not_to raise_error
    end

    it "should be able to make a concise period string" do
      expect(Period.new('2013-01-01', '2013-12-31').to_s).to eq('2013')
      expect(Period.new('2013-04-01', '2013-06-30').to_s).to eq('2013-2Q')
      expect(Period.new('2013-03-01', '2013-03-31').to_s).to eq('2013-03')
      expect(Period.new('2013-03-11', '2013-10-31').to_s).to eq('2013-03-11 to 2013-10-31')
    end

    # Note in the following that first period must begin within self.
    it "should be able to chunk into years" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :year)
      expect(chunks.size).to eq(3)
      expect(chunks[0].first.iso).to eq('2010-01-01')
      expect(chunks[0].last.iso).to eq('2010-12-31')
      expect(chunks[1].first.iso).to eq('2011-01-01')
      expect(chunks[1].last.iso).to eq('2011-12-31')
      expect(chunks[2].first.iso).to eq('2012-01-01')
      expect(chunks[2].last.iso).to eq('2012-12-31')
    end

    it "should be able to chunk into quarters" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :quarter)
      expect(chunks.size).to eq(12)
      expect(chunks[0].first.iso).to eq('2010-01-01')
      expect(chunks[0].last.iso).to eq('2010-03-31')
      expect(chunks[1].first.iso).to eq('2010-04-01')
      expect(chunks[1].last.iso).to eq('2010-06-30')
      expect(chunks[2].first.iso).to eq('2010-07-01')
      expect(chunks[2].last.iso).to eq('2010-09-30')
      expect(chunks.last.first.iso).to eq('2012-10-01')
      expect(chunks.last.last.iso).to eq('2012-12-31')
    end

    it "should be able to chunk into bimonths" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :bimonth)
      expect(chunks.size).to eq(18)
      expect(chunks[0].first.iso).to eq('2010-01-01')
      expect(chunks[0].last.iso).to eq('2010-02-28')
      expect(chunks[1].first.iso).to eq('2010-03-01')
      expect(chunks[1].last.iso).to eq('2010-04-30')
      expect(chunks[2].first.iso).to eq('2010-05-01')
      expect(chunks[2].last.iso).to eq('2010-06-30')
      expect(chunks.last.first.iso).to eq('2012-11-01')
      expect(chunks.last.last.iso).to eq('2012-12-31')
    end

    it "should be able to chunk into months" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :month)
      expect(chunks.size).to eq(36)
      expect(chunks[0].first.iso).to eq('2010-01-01')
      expect(chunks[0].last.iso).to eq('2010-01-31')
      expect(chunks[1].first.iso).to eq('2010-02-01')
      expect(chunks[1].last.iso).to eq('2010-02-28')
      expect(chunks[2].first.iso).to eq('2010-03-01')
      expect(chunks[2].last.iso).to eq('2010-03-31')
      expect(chunks.last.first.iso).to eq('2012-12-01')
      expect(chunks.last.last.iso).to eq('2012-12-31')
    end

    it "should be able to chunk into semimonths" do
      chunks = Period.new('2009-12-25', '2013-01-10').chunks(size: :semimonth)
      expect(chunks.size).to eq(72)
      expect(chunks[0].first.iso).to eq('2010-01-01')
      expect(chunks[0].last.iso).to eq('2010-01-15')
      expect(chunks[1].first.iso).to eq('2010-01-16')
      expect(chunks[1].last.iso).to eq('2010-01-31')
      expect(chunks[2].first.iso).to eq('2010-02-01')
      expect(chunks[2].last.iso).to eq('2010-02-15')
      expect(chunks.last.first.iso).to eq('2012-12-16')
      expect(chunks.last.last.iso).to eq('2012-12-31')
    end

    it "should be able to chunk into biweeks" do
      chunks = Period.new('2009-12-29', '2013-01-10').chunks(size: :biweek)
      expect(chunks.size).to be >=(26*3)
      expect(chunks[0].first.iso).to eq('2010-01-04')
      expect(chunks[0].last.iso).to eq('2010-01-17')
      expect(chunks[1].first.iso).to eq('2010-01-18')
      expect(chunks[1].last.iso).to eq('2010-01-31')
      expect(chunks[2].first.iso).to eq('2010-02-01')
      expect(chunks[2].last.iso).to eq('2010-02-14')
      expect(chunks.last.first.iso).to eq('2012-12-17')
      expect(chunks.last.last.iso).to eq('2012-12-30')
    end

    it "should be able to chunk into weeks" do
      chunks = Period.new('2010-01-01', '2012-12-31').chunks(size: :week)
      expect(chunks.size).to be >=(52*3)
      expect(chunks[0].first.iso).to eq('2010-01-04')
      expect(chunks[0].last.iso).to eq('2010-01-10')
      expect(chunks[1].first.iso).to eq('2010-01-11')
      expect(chunks[1].last.iso).to eq('2010-01-17')
      expect(chunks[2].first.iso).to eq('2010-01-18')
      expect(chunks[2].last.iso).to eq('2010-01-24')
      expect(chunks.last.first.iso).to eq('2012-12-24')
      expect(chunks.last.last.iso).to eq('2012-12-30')
    end

    it "should be able to chunk into days" do
      chunks = Period.new('2012-12-28', '2012-12-31').chunks(size: :day)
      expect(chunks.size).to eq(4)
      expect(chunks[0].first.iso).to eq('2012-12-28')
      expect(chunks[0].last.iso).to eq('2012-12-28')
      expect(chunks[1].first.iso).to eq('2012-12-29')
      expect(chunks[1].last.iso).to eq('2012-12-29')
      expect(chunks[2].first.iso).to eq('2012-12-30')
      expect(chunks[2].last.iso).to eq('2012-12-30')
      expect(chunks.last.first.iso).to eq('2012-12-31')
      expect(chunks.last.last.iso).to eq('2012-12-31')
    end

    it "should not include a partial final chunk by default" do
      chunks = Period.new('2012-01-01', '2012-03-30').chunks(size: :month)
      expect(chunks.size).to eq(2)
    end

    it "should include a partial final chunk if partial_last" do
      chunks = Period.new('2012-01-01', '2012-03-30').
        chunks(size: :month, partial_last: true)
      expect(chunks.size).to eq(3)
      expect(chunks.last.first).to eq(Date.parse('2012-03-01'))
      expect(chunks.last.last).to eq(Date.parse('2012-03-30'))
    end

    it "should include a final chunk beyond end_date if round_up" do
      chunks = Period.new('2012-01-01', '2012-03-30').
        chunks(size: :month, round_up_last: true)
      expect(chunks.size).to eq(3)
      expect(chunks.last.first).to eq(Date.parse('2012-03-01'))
      expect(chunks.last.last).to eq(Date.parse('2012-03-31'))
    end

    it "should not include a partial initial chunk by default" do
      chunks = Period.new('2012-01-13', '2012-03-31').chunks(size: :month)
      expect(chunks.size).to eq(2)
      expect(chunks[0].first).to eq(Date.parse('2012-02-01'))
      expect(chunks[0].last).to eq(Date.parse('2012-02-29'))
    end

    it "should include a partial initial chunk by if partial_first" do
      chunks = Period.new('2012-01-13', '2012-03-31').
        chunks(size: :month, partial_first: true)
      expect(chunks.size).to eq(3)
      expect(chunks[0].first).to eq(Date.parse('2012-01-13'))
      expect(chunks[0].last).to eq(Date.parse('2012-01-31'))
    end

    it "should include a final chunk beyond end_date if round_up" do
      chunks = Period.new('2012-01-01', '2012-03-30').
        chunks(size: :month, round_up_last: true)
      expect(chunks.size).to eq(3)
      expect(chunks.last.first).to eq(Date.parse('2012-03-01'))
      expect(chunks.last.last).to eq(Date.parse('2012-03-31'))
    end

    it "should be able to its chunk_sym" do
      expect(Period.new('2013-01-01', '2013-12-31').chunk_sym).to eq(:year)
      expect(Period.new('2012-01-01', '2013-12-31').chunk_sym).to_not eq(:year)

      expect(Period.new('2013-04-01', '2013-06-30').chunk_sym).to eq(:quarter)
      expect(Period.new('2013-04-01', '2013-09-30').chunk_sym).to_not eq(:quarter)

      expect(Period.new('2013-03-01', '2013-04-30').chunk_sym).to eq(:bimonth)
      expect(Period.new('2013-03-01', '2013-06-30').chunk_sym).to_not eq(:bimonth)

      expect(Period.new('2013-04-01', '2013-04-30').chunk_sym).to eq(:month)
      expect(Period.new('2013-04-01', '2013-05-30').chunk_sym).to_not eq(:month)

      expect(Period.new('2013-05-16', '2013-05-31').chunk_sym).to eq(:semimonth)
      expect(Period.new('2013-05-16', '2013-06-30').chunk_sym).to_not eq(:semimonth)

      expect(Period.new('2013-11-04', '2013-11-17').chunk_sym).to eq(:biweek)
      expect(Period.new('2013-11-04', '2013-11-24').chunk_sym).to_not eq(:biweek)

      expect(Period.new('2013-11-11', '2013-11-17').chunk_sym).to eq(:week)
      expect(Period.new('2013-11-11', '2013-11-24').chunk_sym).to_not eq(:week)

      expect(Period.new('2013-11-10', '2013-11-10').chunk_sym).to eq(:day)
      expect(Period.new('2013-11-10', '2013-11-11').chunk_sym).to_not eq(:day)

      expect(Period.new('2013-11-02', '2013-12-16').chunk_sym).to eq(:irregular)
    end
  end
end
