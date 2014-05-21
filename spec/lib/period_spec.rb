require 'spec_helper'

describe Period do
  before :each do
    # Pretend it is this date. Not at beg or end of year, quarter,
    # month, or week.  It is a Wednesday
    Date.stub(:today).and_return(Date.parse('2012-07-18'))
    @test_today = Date.parse('2012-07-18')
  end

  describe "initialization" do

    it "should be initializable with date strings" do
      Period.new('2013-01-01', '2013-12-13').should be_instance_of Period
    end

    it "should be initializable with Dates" do
      Period.new(Date.parse('2013-01-01'), Date.parse('2013-12-13')).
        should be_instance_of Period
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

    it "should know the days in a chunk sym" do
      Period.chunk_sym_to_days(:year).should eq(365)
      Period.chunk_sym_to_days(:quarter).should eq(90)
      Period.chunk_sym_to_days(:bimonth).should eq(60)
      Period.chunk_sym_to_days(:month).should eq(30)
      Period.chunk_sym_to_days(:semimonth).should eq(15)
      Period.chunk_sym_to_days(:biweek).should eq(14)
      Period.chunk_sym_to_days(:week).should eq(7)
      Period.chunk_sym_to_days(:day).should eq(1)
      Period.chunk_sym_to_days(:irregular).should eq(30)
      expect {
        Period.chunk_sym_to_days(:eon)
      }.to raise_error ArgumentError
    end

    it "should know the chunk sym for given days but only :year, :quarter, :month" do
      (356..376).each { |d| Period.days_to_chunk_sym(d).should eq(:year) }
      (86..96).each { |d| Period.days_to_chunk_sym(d).should eq(:quarter) }
      (28..31).each { |d| Period.days_to_chunk_sym(d).should eq(:month) }
      Period.days_to_chunk_sym(7).should eq(:week)
      Period.days_to_chunk_sym(1).should eq(:day)
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
      (pp1 == pp2).should be_true
      (pp1 == pp3).should_not be_true
    end

    it "should be able to convert into a Range" do
      pp = Period.new('2013-01-01', '2013-12-31')
      rr = Period.new('2013-01-01', '2013-12-31').to_range
      rr.should be_instance_of Range
      rr.first.should eq(pp.first)
      rr.first.should eq(pp.first)
    end

    it "should be able to tell if it contains a date" do
      pp = Period.new('2013-01-01', '2013-12-31')
      pp.contains?(Date.parse('2013-01-01')).should be_true
      pp.contains?(Date.parse('2013-07-04')).should be_true
      pp.contains?(Date.parse('2013-12-31')).should be_true
      pp.contains?(Date.parse('2012-07-04')).should be_false
    end

    it "should be able to make a concise period string" do
      Period.new('2013-01-01', '2013-12-31').to_s.
        should eq('2013')
      Period.new('2013-04-01', '2013-06-30').to_s.
        should eq('2013-2Q')
      Period.new('2013-03-01', '2013-03-31').to_s.
        should eq('2013-03')
      Period.new('2013-03-11', '2013-10-31').to_s.
        should eq('2013-03-11 to 2013-10-31')
    end

    # Note in the following that first period must begin within self.
    it "should be able to chunk into years" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :year)
      chunks.size.should eq(3)
      chunks[0].first.iso.should eq('2010-01-01')
      chunks[0].last.iso.should eq('2010-12-31')
      chunks[1].first.iso.should eq('2011-01-01')
      chunks[1].last.iso.should eq('2011-12-31')
      chunks[2].first.iso.should eq('2012-01-01')
      chunks[2].last.iso.should eq('2012-12-31')
    end

    it "should be able to chunk into quarters" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :quarter)
      chunks.size.should eq(12)
      chunks[0].first.iso.should eq('2010-01-01')
      chunks[0].last.iso.should eq('2010-03-31')
      chunks[1].first.iso.should eq('2010-04-01')
      chunks[1].last.iso.should eq('2010-06-30')
      chunks[2].first.iso.should eq('2010-07-01')
      chunks[2].last.iso.should eq('2010-09-30')
      chunks.last.first.iso.should eq('2012-10-01')
      chunks.last.last.iso.should eq('2012-12-31')
    end

    it "should be able to chunk into bimonths" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :bimonth)
      chunks.size.should eq(18)
      chunks[0].first.iso.should eq('2010-01-01')
      chunks[0].last.iso.should eq('2010-02-28')
      chunks[1].first.iso.should eq('2010-03-01')
      chunks[1].last.iso.should eq('2010-04-30')
      chunks[2].first.iso.should eq('2010-05-01')
      chunks[2].last.iso.should eq('2010-06-30')
      chunks.last.first.iso.should eq('2012-11-01')
      chunks.last.last.iso.should eq('2012-12-31')
    end

    it "should be able to chunk into months" do
      chunks = Period.new('2009-12-15', '2013-01-10').chunks(size: :month)
      chunks.size.should eq(36)
      chunks[0].first.iso.should eq('2010-01-01')
      chunks[0].last.iso.should eq('2010-01-31')
      chunks[1].first.iso.should eq('2010-02-01')
      chunks[1].last.iso.should eq('2010-02-28')
      chunks[2].first.iso.should eq('2010-03-01')
      chunks[2].last.iso.should eq('2010-03-31')
      chunks.last.first.iso.should eq('2012-12-01')
      chunks.last.last.iso.should eq('2012-12-31')
    end

    it "should be able to chunk into semimonths" do
      chunks = Period.new('2009-12-25', '2013-01-10').chunks(size: :semimonth)
      chunks.size.should eq(72)
      chunks[0].first.iso.should eq('2010-01-01')
      chunks[0].last.iso.should eq('2010-01-15')
      chunks[1].first.iso.should eq('2010-01-16')
      chunks[1].last.iso.should eq('2010-01-31')
      chunks[2].first.iso.should eq('2010-02-01')
      chunks[2].last.iso.should eq('2010-02-15')
      chunks.last.first.iso.should eq('2012-12-16')
      chunks.last.last.iso.should eq('2012-12-31')
    end

    it "should be able to chunk into biweeks" do
      chunks = Period.new('2009-12-29', '2013-01-10').chunks(size: :biweek)
      expect(chunks.size).to be >=(26*3)
      chunks[0].first.iso.should eq('2010-01-04')
      chunks[0].last.iso.should eq('2010-01-17')
      chunks[1].first.iso.should eq('2010-01-18')
      chunks[1].last.iso.should eq('2010-01-31')
      chunks[2].first.iso.should eq('2010-02-01')
      chunks[2].last.iso.should eq('2010-02-14')
      chunks.last.first.iso.should eq('2012-12-17')
      chunks.last.last.iso.should eq('2012-12-30')
    end

    it "should be able to chunk into weeks" do
      chunks = Period.new('2010-01-01', '2012-12-31').chunks(size: :week)
      expect(chunks.size).to be >=(52*3)
      chunks[0].first.iso.should eq('2010-01-04')
      chunks[0].last.iso.should eq('2010-01-10')
      chunks[1].first.iso.should eq('2010-01-11')
      chunks[1].last.iso.should eq('2010-01-17')
      chunks[2].first.iso.should eq('2010-01-18')
      chunks[2].last.iso.should eq('2010-01-24')
      chunks.last.first.iso.should eq('2012-12-24')
      chunks.last.last.iso.should eq('2012-12-30')
    end

    it "should be able to chunk into days" do
      chunks = Period.new('2012-12-28', '2012-12-31').chunks(size: :day)
      chunks.size.should eq(4)
      chunks[0].first.iso.should eq('2012-12-28')
      chunks[0].last.iso.should eq('2012-12-28')
      chunks[1].first.iso.should eq('2012-12-29')
      chunks[1].last.iso.should eq('2012-12-29')
      chunks[2].first.iso.should eq('2012-12-30')
      chunks[2].last.iso.should eq('2012-12-30')
      chunks.last.first.iso.should eq('2012-12-31')
      chunks.last.last.iso.should eq('2012-12-31')
    end

    it "should not include a partial final chunk by default" do
      chunks = Period.new('2012-01-01', '2012-03-30').chunks(size: :month)
      chunks.size.should eq(2)
    end

    it "should include a partial final chunk if partial_last" do
      chunks = Period.new('2012-01-01', '2012-03-30').
        chunks(size: :month, partial_last: true)
      chunks.size.should eq(3)
      chunks.last.first.should eq(Date.parse('2012-03-01'))
      chunks.last.last.should eq(Date.parse('2012-03-30'))
    end

    it "should include a final chunk beyond end_date if round_up" do
      chunks = Period.new('2012-01-01', '2012-03-30').
        chunks(size: :month, round_up_last: true)
      chunks.size.should eq(3)
      chunks.last.first.should eq(Date.parse('2012-03-01'))
      chunks.last.last.should eq(Date.parse('2012-03-31'))
    end

    it "should not include a partial initial chunk by default" do
      chunks = Period.new('2012-01-13', '2012-03-31').chunks(size: :month)
      chunks.size.should eq(2)
      chunks[0].first.should eq(Date.parse('2012-02-01'))
      chunks[0].last.should eq(Date.parse('2012-02-29'))
    end

    it "should include a partial initial chunk by if partial_first" do
      chunks = Period.new('2012-01-13', '2012-03-31').
        chunks(size: :month, partial_first: true)
      chunks.size.should eq(3)
      chunks[0].first.should eq(Date.parse('2012-01-13'))
      chunks[0].last.should eq(Date.parse('2012-01-31'))
    end

    it "should include a final chunk beyond end_date if round_up" do
      chunks = Period.new('2012-01-01', '2012-03-30').
        chunks(size: :month, round_up_last: true)
      chunks.size.should eq(3)
      chunks.last.first.should eq(Date.parse('2012-03-01'))
      chunks.last.last.should eq(Date.parse('2012-03-31'))
    end

    it "should be able to its chunk_sym" do
      Period.new('2013-01-01', '2013-12-31').chunk_sym.should eq(:year)
      Period.new('2012-01-01', '2013-12-31').chunk_sym.should_not eq(:year)

      Period.new('2013-04-01', '2013-06-30').chunk_sym.should eq(:quarter)
      Period.new('2013-04-01', '2013-09-30').chunk_sym.should_not eq(:quarter)

      Period.new('2013-03-01', '2013-04-30').chunk_sym.should eq(:bimonth)
      Period.new('2013-03-01', '2013-06-30').chunk_sym.should_not eq(:bimonth)

      Period.new('2013-04-01', '2013-04-30').chunk_sym.should eq(:month)
      Period.new('2013-04-01', '2013-05-30').chunk_sym.should_not eq(:month)

      Period.new('2013-05-16', '2013-05-31').chunk_sym.should eq(:semimonth)
      Period.new('2013-05-16', '2013-06-30').chunk_sym.should_not eq(:semimonth)

      Period.new('2013-11-04', '2013-11-17').chunk_sym.should eq(:biweek)
      Period.new('2013-11-04', '2013-11-24').chunk_sym.should_not eq(:biweek)

      Period.new('2013-11-11', '2013-11-17').chunk_sym.should eq(:week)
      Period.new('2013-11-11', '2013-11-24').chunk_sym.should_not eq(:week)

      Period.new('2013-11-10', '2013-11-10').chunk_sym.should eq(:day)
      Period.new('2013-11-10', '2013-11-11').chunk_sym.should_not eq(:day)

      Period.new('2013-11-02', '2013-12-16').chunk_sym.should eq(:irregular)
    end
  end
end
