require 'spec_helper'

describe Date do
  before :each do
    # Pretend it is this date. Not at beg or end of year, quarter,
    # month, or week.  It is a Wednesday
    allow(Date).to receive_messages(:today => Date.parse('2012-07-18'))
    allow(Date).to receive_messages(:current => Date.parse('2012-07-18'))
  end

  describe "class methods" do

    describe "parse_spec" do

      it "should choke if spec type is neither :from or :to" do
        expect {
          Date.parse_spec('2011-07-15', :form)
        }.to raise_error
      end

      it "should parse plain iso dates correctly" do
        expect(Date.parse_spec('2011-07-15')).to eq Date.parse('2011-07-15')
        expect(Date.parse_spec('2011-08-05')).to eq Date.parse('2011-08-05')
      end

      it "should parse week numbers such as 'W23' or '23W' correctly" do
        expect(Date.parse_spec('W1')).to eq Date.parse('2012-01-02')
        expect(Date.parse_spec('W23')).to eq Date.parse('2012-06-04')
        expect(Date.parse_spec('W23', :to)).to eq Date.parse('2012-06-10')
        expect(Date.parse_spec('23W')).to eq Date.parse('2012-06-04')
        expect(Date.parse_spec('23W', :to)).to eq Date.parse('2012-06-10')
        expect {
          Date.parse_spec('W83', :to)
        }.to raise_error
      end

      it "should parse year-week numbers such as 'YYYY-W23' or 'YYYY-23W' correctly" do
        expect(Date.parse_spec('2003-W1')).to eq Date.parse('2002-12-30')
        expect(Date.parse_spec('2003-W1', :to)).to eq Date.parse('2003-01-05')
        expect(Date.parse_spec('2003-W23')).to eq Date.parse('2003-06-02')
        expect(Date.parse_spec('2003-W23', :to)).to eq Date.parse('2003-06-08')
        expect(Date.parse_spec('2003-23W')).to eq Date.parse('2003-06-02')
        expect(Date.parse_spec('2003-23W', :to)).to eq Date.parse('2003-06-08')
        expect {
          Date.parse_spec('2003-W83', :to)
        }.to raise_error
      end

      it "should parse year-quarter specs such as YYYY-NQ or YYYY-QN" do
        expect(Date.parse_spec('2011-4Q', :from)).to eq Date.parse('2011-10-01')
        expect(Date.parse_spec('2011-4Q', :to)).to eq Date.parse('2011-12-31')
        expect(Date.parse_spec('2011-Q4', :from)).to eq Date.parse('2011-10-01')
        expect(Date.parse_spec('2011-Q4', :to)).to eq Date.parse('2011-12-31')
        expect { Date.parse_spec('2011-5Q') }.to raise_error
      end

      it "should parse quarter-only specs such as NQ or QN" do
        expect(Date.parse_spec('4Q', :from)).to eq Date.parse('2012-10-01')
        expect(Date.parse_spec('4Q', :to)).to eq Date.parse('2012-12-31')
        expect(Date.parse_spec('Q4', :from)).to eq Date.parse('2012-10-01')
        expect(Date.parse_spec('Q4', :to)).to eq Date.parse('2012-12-31')
        expect { Date.parse_spec('5Q') }.to raise_error
      end

      it "should parse year-month specs such as YYYY-MM" do
        expect(Date.parse_spec('2010-5', :from)).to eq Date.parse('2010-05-01')
        expect(Date.parse_spec('2010-5', :to)).to eq Date.parse('2010-05-31')
        expect { Date.parse_spec('2010-13') }.to raise_error
      end

      it "should parse month-only specs such as MM" do
        expect(Date.parse_spec('10', :from)).to eq Date.parse('2012-10-01')
        expect(Date.parse_spec('10', :to)).to eq Date.parse('2012-10-31')
        expect { Date.parse_spec('99') }.to raise_error
        expect { Date.parse_spec('011') }.to raise_error
      end

      it "should parse year-only specs such as YYYY" do
        expect(Date.parse_spec('2010', :from)).to eq Date.parse('2010-01-01')
        expect(Date.parse_spec('2010', :to)).to eq Date.parse('2010-12-31')
        expect { Date.parse_spec('99999') }.to raise_error
      end

      it "should parse relative day names: today, yesterday" do
        expect(Date.parse_spec('today')).to eq Date.current
        expect(Date.parse_spec('this_day')).to eq Date.current
        expect(Date.parse_spec('yesterday')).to eq Date.current - 1.day
        expect(Date.parse_spec('last_day')).to eq Date.current - 1.day
      end

      it "should parse relative weeks: this_week, last_week" do
        expect(Date.parse_spec('this_week')).to eq Date.parse('2012-07-16')
        expect(Date.parse_spec('this_week', :to)).to eq Date.parse('2012-07-22')
        expect(Date.parse_spec('last_week')).to eq Date.parse('2012-07-09')
        expect(Date.parse_spec('last_week', :to)).to eq Date.parse('2012-07-15')
      end

      it "should parse relative biweeks: this_biweek, last_biweek" do
        expect(Date.parse_spec('this_biweek')).to eq Date.parse('2012-07-16')
        expect(Date.parse_spec('this_biweek', :to)).to eq Date.parse('2012-07-29')
        expect(Date.parse_spec('last_biweek')).to eq Date.parse('2012-07-02')
        expect(Date.parse_spec('last_biweek', :to)).to eq Date.parse('2012-07-15')
      end

      it "should parse relative months: this_semimonth, last_semimonth" do
        expect(Date.parse_spec('this_semimonth')).to eq Date.parse('2012-07-16')
        expect(Date.parse_spec('this_semimonth', :to)).to eq Date.parse('2012-07-31')
        expect(Date.parse_spec('last_semimonth')).to eq Date.parse('2012-07-01')
        expect(Date.parse_spec('last_semimonth', :to)).to eq Date.parse('2012-07-15')
      end

      it "should parse relative months: this_month, last_month" do
        expect(Date.parse_spec('this_month')).to eq Date.parse('2012-07-01')
        expect(Date.parse_spec('this_month', :to)).to eq Date.parse('2012-07-31')
        expect(Date.parse_spec('last_month')).to eq Date.parse('2012-06-01')
        expect(Date.parse_spec('last_month', :to)).to eq Date.parse('2012-06-30')
      end

      it "should parse relative bimonths: this_bimonth, last_bimonth" do
        expect(Date.parse_spec('this_bimonth')).to eq Date.parse('2012-07-01')
        expect(Date.parse_spec('this_bimonth', :to)).to eq Date.parse('2012-08-31')
        expect(Date.parse_spec('last_bimonth')).to eq Date.parse('2012-05-01')
        expect(Date.parse_spec('last_bimonth', :to)).to eq Date.parse('2012-06-30')
      end

      it "should parse relative quarters: this_quarter, last_quarter" do
        expect(Date.parse_spec('this_quarter')).to eq Date.parse('2012-07-01')
        expect(Date.parse_spec('this_quarter', :to)).to eq Date.parse('2012-09-30')
        expect(Date.parse_spec('last_quarter')).to eq Date.parse('2012-04-01')
        expect(Date.parse_spec('last_quarter', :to)).to eq Date.parse('2012-06-30')
      end

      it "should parse relative years: this_year, last_year" do
        expect(Date.parse_spec('this_year')).to eq Date.parse('2012-01-01')
        expect(Date.parse_spec('this_year', :to)).to eq Date.parse('2012-12-31')
        expect(Date.parse_spec('last_year')).to eq Date.parse('2011-01-01')
        expect(Date.parse_spec('last_year', :to)).to eq Date.parse('2011-12-31')
      end

      it "should parse forever and never" do
        expect(Date.parse_spec('forever')).to eq Date::BOT
        expect(Date.parse_spec('forever', :to)).to eq Date::EOT
        expect(Date.parse_spec('never')).to be_nil
      end
    end

    it "should be able to parse an American-style date" do
      expect(Date.parse_american('2/12/2011').iso).to eq('2011-02-12')
      expect(Date.parse_american('2 / 12/ 2011').iso).to eq('2011-02-12')
      expect(Date.parse_american('2 / 1 / 2011').iso).to eq('2011-02-01')
      expect(Date.parse_american('  2 / 1 / 2011  ').iso).to eq('2011-02-01')
      expect(Date.parse_american('  2 / 1 / 15  ').iso).to eq('2015-02-01')
    end
  end

  describe "instance methods" do

    it "should know if its a weekend of a weekday" do
      expect(Date.parse('2014-05-17')).to be_weekend
      expect(Date.parse('2014-05-17')).to_not be_weekday
      expect(Date.parse('2014-05-18')).to be_weekend
      expect(Date.parse('2014-05-18')).to_not be_weekday

      expect(Date.parse('2014-05-22')).to be_weekday
      expect(Date.parse('2014-05-22')).to_not be_weekend
    end

    it "should know its pred and succ (for Range)" do
      expect(Date.today.pred).to eq (Date.today - 1)
      expect(Date.today.succ).to eq (Date.today + 1)
    end

    it "should be able to print itself as an American-style date" do
      expect(Date.parse('2011-02-12').american).to eq('2/12/2011')
    end

    it "should be able to print itself in iso form" do
      expect(Date.today.iso).to eq '2012-07-18'
    end

    it "should be able to print itself in org form" do
      expect(Date.today.org).to eq('[2012-07-18 Wed]')
      expect((Date.today + 1.day).org).to eq('[2012-07-19 Thu]')
    end

    it "should be able to print itself in eng form" do
      expect(Date.today.eng).to eq('July 18, 2012')
      expect((Date.today + 1.day).eng).to eq('July 19, 2012')
    end

    it "should be able to state its quarter" do
      expect(Date.today.quarter).to eq(3)
      expect(Date.parse('2012-02-29').quarter).to eq(1)
      expect(Date.parse('2012-01-01').quarter).to eq(1)
      expect(Date.parse('2012-03-31').quarter).to eq(1)
      expect(Date.parse('2012-04-01').quarter).to eq(2)
      expect(Date.parse('2012-05-15').quarter).to eq(2)
      expect(Date.parse('2012-06-30').quarter).to eq(2)
      expect(Date.parse('2012-07-01').quarter).to eq(3)
      expect(Date.parse('2012-08-15').quarter).to eq(3)
      expect(Date.parse('2012-09-30').quarter).to eq(3)
      expect(Date.parse('2012-10-01').quarter).to eq(4)
      expect(Date.parse('2012-11-15').quarter).to eq(4)
      expect(Date.parse('2012-12-31').quarter).to eq(4)
    end

    it "should know about years" do
      expect(Date.parse('2013-01-01')).to be_beginning_of_year
      expect(Date.parse('2013-12-31')).to be_end_of_year
      expect(Date.parse('2013-04-01')).to_not be_beginning_of_year
      expect(Date.parse('2013-12-30')).to_not be_end_of_year
    end

    it "should know about quarters" do
      expect(Date.parse('2013-01-01')).to be_beginning_of_quarter
      expect(Date.parse('2013-12-31')).to be_end_of_quarter
      expect(Date.parse('2013-04-01')).to be_beginning_of_quarter
      expect(Date.parse('2013-06-30')).to be_end_of_quarter
      expect(Date.parse('2013-05-01')).to_not be_beginning_of_quarter
      expect(Date.parse('2013-07-31')).to_not be_end_of_quarter
    end

    it "should know about bimonths" do
      expect(Date.parse('2013-11-04').beginning_of_bimonth).to eq Date.parse('2013-11-01')
      expect(Date.parse('2013-11-04').end_of_bimonth).to eq Date.parse('2013-12-31')
      expect(Date.parse('2013-03-01')).to be_beginning_of_bimonth
      expect(Date.parse('2013-04-30')).to be_end_of_bimonth
      expect(Date.parse('2013-01-01')).to be_beginning_of_bimonth
      expect(Date.parse('2013-12-31')).to be_end_of_bimonth
      expect(Date.parse('2013-05-01')).to be_beginning_of_bimonth
      expect(Date.parse('2013-06-30')).to be_end_of_bimonth
      expect(Date.parse('2013-06-01')).to_not be_beginning_of_bimonth
      expect(Date.parse('2013-07-31')).to_not be_end_of_bimonth
    end

    it "should know about months" do
      expect(Date.parse('2013-01-01')).to be_beginning_of_month
      expect(Date.parse('2013-12-31')).to be_end_of_month
      expect(Date.parse('2013-05-01')).to be_beginning_of_month
      expect(Date.parse('2013-07-31')).to be_end_of_month
      expect(Date.parse('2013-05-02')).to_not be_beginning_of_month
      expect(Date.parse('2013-07-30')).to_not be_end_of_month
    end

    it "should know about semimonths" do
      expect(Date.parse('2013-11-24').beginning_of_semimonth).to eq Date.parse('2013-11-16')
      expect(Date.parse('2013-11-04').beginning_of_semimonth).to eq Date.parse('2013-11-01')
      expect(Date.parse('2013-11-04').end_of_semimonth).to eq Date.parse('2013-11-15')
      expect(Date.parse('2013-11-24').end_of_semimonth).to eq Date.parse('2013-11-30')
      expect(Date.parse('2013-03-01')).to be_beginning_of_semimonth
      expect(Date.parse('2013-03-16')).to be_beginning_of_semimonth
      expect(Date.parse('2013-04-15')).to be_end_of_semimonth
      expect(Date.parse('2013-04-30')).to be_end_of_semimonth
    end

    it "should know about biweeks" do
      expect(Date.parse('2013-11-07').beginning_of_biweek).to eq Date.parse('2013-11-04')
      expect(Date.parse('2013-11-07').end_of_biweek).to eq Date.parse('2013-11-17')
      expect(Date.parse('2013-03-11')).to be_beginning_of_biweek
      expect(Date.parse('2013-03-24')).to be_end_of_biweek
    end

    it "should know about weeks" do
      expect(Date.parse('2013-11-04')).to be_beginning_of_week
      expect(Date.parse('2013-11-10')).to be_end_of_week
      expect(Date.parse('2013-12-02')).to be_beginning_of_week
      expect(Date.parse('2013-12-08')).to be_end_of_week
      expect(Date.parse('2013-10-13')).to_not be_beginning_of_week
      expect(Date.parse('2013-10-19')).to_not be_end_of_week
    end

    it "should know the beginning of chunks" do
      expect(Date.parse('2013-11-04').beginning_of_chunk(:year)).to eq Date.parse('2013-01-01')
      expect(Date.parse('2013-11-04').beginning_of_chunk(:quarter)).to eq Date.parse('2013-10-01')
      expect(Date.parse('2013-12-04').beginning_of_chunk(:bimonth)).to eq Date.parse('2013-11-01')
      expect(Date.parse('2013-11-04').beginning_of_chunk(:month)).to eq Date.parse('2013-11-01')
      expect(Date.parse('2013-11-04').beginning_of_chunk(:semimonth)).to eq Date.parse('2013-11-01')
      expect(Date.parse('2013-11-24').beginning_of_chunk(:semimonth)).to eq Date.parse('2013-11-16')
      expect(Date.parse('2013-11-08').beginning_of_chunk(:biweek)).to eq Date.parse('2013-11-04')
      expect(Date.parse('2013-11-08').beginning_of_chunk(:week)).to eq Date.parse('2013-11-04')
      expect {
        Date.parse('2013-11-04').beginning_of_chunk(:wek)
      }.to raise_error
    end

    it "should know the end of chunks" do
      expect(Date.parse('2013-07-04').end_of_chunk(:year)).to eq Date.parse('2013-12-31')
      expect(Date.parse('2013-07-04').end_of_chunk(:quarter)).to eq Date.parse('2013-09-30')
      expect(Date.parse('2013-12-04').end_of_chunk(:bimonth)).to eq Date.parse('2013-12-31')
      expect(Date.parse('2013-07-04').end_of_chunk(:month)).to eq Date.parse('2013-07-31')
      expect(Date.parse('2013-11-04').end_of_chunk(:semimonth)).to eq Date.parse('2013-11-15')
      expect(Date.parse('2013-11-24').end_of_chunk(:semimonth)).to eq Date.parse('2013-11-30')
      expect(Date.parse('2013-11-08').end_of_chunk(:biweek)).to eq Date.parse('2013-11-17')
      expect(Date.parse('2013-07-04').end_of_chunk(:week)).to eq Date.parse('2013-07-07')
      expect {
        Date.parse('2013-11-04').end_of_chunk(:wek)
      }.to raise_error
    end

    it "should know how to expand to chunk periods" do
      expect(Date.parse('2013-07-04').expand_to_period(:year)).to eq Period.new('2013-01-01', '2013-12-31')
      expect(Date.parse('2013-07-04').expand_to_period(:quarter)).to eq Period.new('2013-07-01', '2013-09-30')
      expect(Date.parse('2013-07-04').expand_to_period(:bimonth)).to eq Period.new('2013-07-01', '2013-08-31')
      expect(Date.parse('2013-07-04').expand_to_period(:month)).to eq Period.new('2013-07-01', '2013-07-31')
      expect(Date.parse('2013-07-04').expand_to_period(:semimonth)).to eq Period.new('2013-07-01', '2013-07-15')
      expect(Date.parse('2013-07-04').expand_to_period(:biweek)).to eq Period.new('2013-07-01', '2013-07-14')
      expect(Date.parse('2013-07-04').expand_to_period(:week)).to eq Period.new('2013-07-01', '2013-07-07')
      expect(Date.parse('2013-07-04').expand_to_period(:day)).to eq Period.new('2013-07-04', '2013-07-04')
    end
  end
end
