require 'spec_helper'

describe Date do
  before :each do
    # Pretend it is this date. Not at beg or end of year, quarter,
    # month, or week.  It is a Wednesday
    Date.stub(:current).and_return(Date.parse('2012-07-18'))
    Date.stub(:today).and_return(Date.parse('2012-07-18'))
    @test_today = Date.parse('2012-07-18')
  end

  describe "class methods" do

    describe "parse_spec" do

      it "should choke if spec type is neither :from or :to" do
        expect {
          Date.parse_spec('2011-07-15', :form)
        }.to raise_error
      end

      it "should parse plain iso dates correctly" do
        Date.parse_spec('2011-07-15').should eq Date.parse('2011-07-15')
        Date.parse_spec('2011-08-05').should eq Date.parse('2011-08-05')
      end

      it "should parse week numbers such as 'W23' correctly" do
        Date.parse_spec('W1').should eq Date.parse('2012-01-02')
        Date.parse_spec('W23').should eq Date.parse('2012-06-04')
        Date.parse_spec('W23', :to).should eq Date.parse('2012-06-10')
        expect {
          Date.parse_spec('W83', :to)
        }.to raise_error
      end

      it "should parse year-week numbers such as 'YYYY-W23' correctly" do
        Date.parse_spec('2003-W1').should eq Date.parse('2002-12-30')
        Date.parse_spec('2003-W1', :to).should eq Date.parse('2003-01-05')
        Date.parse_spec('2003-W23').should eq Date.parse('2003-06-02')
        Date.parse_spec('2003-W23', :to).should eq Date.parse('2003-06-08')
        expect {
          Date.parse_spec('2003-W83', :to)
        }.to raise_error
      end

      it "should parse year-quarter specs such as YYYY-NQ" do
        Date.parse_spec('2011-4Q', :from).should eq Date.parse('2011-10-01')
        Date.parse_spec('2011-4Q', :to).should eq Date.parse('2011-12-31')
        expect { Date.parse_spec('2011-5Q') }.to raise_error
      end

      it "should parse quarter-only specs such as NQ" do
        Date.parse_spec('4Q', :from).should eq Date.parse('2012-10-01')
        Date.parse_spec('4Q', :to).should eq Date.parse('2012-12-31')
        expect { Date.parse_spec('5Q') }.to raise_error
      end

      it "should parse year-month specs such as YYYY-MM" do
        Date.parse_spec('2010-5', :from).should eq Date.parse('2010-05-01')
        Date.parse_spec('2010-5', :to).should eq Date.parse('2010-05-31')
        expect { Date.parse_spec('2010-13') }.to raise_error
      end

      it "should parse month-only specs such as MM" do
        Date.parse_spec('10', :from).should eq Date.parse('2012-10-01')
        Date.parse_spec('10', :to).should eq Date.parse('2012-10-31')
        expect { Date.parse_spec('99') }.to raise_error
        expect { Date.parse_spec('011') }.to raise_error
      end

      it "should parse year-only specs such as YYYY" do
        Date.parse_spec('2010', :from).should eq Date.parse('2010-01-01')
        Date.parse_spec('2010', :to).should eq Date.parse('2010-12-31')
        expect { Date.parse_spec('99999') }.to raise_error
      end

      it "should parse relative day names: today, yesterday" do
        Date.parse_spec('today').should eq Date.current
        Date.parse_spec('this_day').should eq Date.current
        Date.parse_spec('yesterday').should eq Date.current - 1.day
        Date.parse_spec('last_day').should eq Date.current - 1.day
      end

      it "should parse relative weeks: this_week, last_week" do
        Date.parse_spec('this_week').should eq Date.parse('2012-07-16')
        Date.parse_spec('this_week', :to).should eq Date.parse('2012-07-22')
        Date.parse_spec('last_week').should eq Date.parse('2012-07-09')
        Date.parse_spec('last_week', :to).should eq Date.parse('2012-07-15')
      end

      it "should parse relative biweeks: this_biweek, last_biweek" do
        Date.parse_spec('this_biweek').should eq Date.parse('2012-07-16')
        Date.parse_spec('this_biweek', :to).should eq Date.parse('2012-07-29')
        Date.parse_spec('last_biweek').should eq Date.parse('2012-07-02')
        Date.parse_spec('last_biweek', :to).should eq Date.parse('2012-07-15')
      end

      it "should parse relative months: this_semimonth, last_semimonth" do
        Date.parse_spec('this_semimonth').should eq Date.parse('2012-07-16')
        Date.parse_spec('this_semimonth', :to).should eq Date.parse('2012-07-31')
        Date.parse_spec('last_semimonth').should eq Date.parse('2012-07-01')
        Date.parse_spec('last_semimonth', :to).should eq Date.parse('2012-07-15')
      end

      it "should parse relative months: this_month, last_month" do
        Date.parse_spec('this_month').should eq Date.parse('2012-07-01')
        Date.parse_spec('this_month', :to).should eq Date.parse('2012-07-31')
        Date.parse_spec('last_month').should eq Date.parse('2012-06-01')
        Date.parse_spec('last_month', :to).should eq Date.parse('2012-06-30')
      end

      it "should parse relative bimonths: this_bimonth, last_bimonth" do
        Date.parse_spec('this_bimonth').should eq Date.parse('2012-07-01')
        Date.parse_spec('this_bimonth', :to).should eq Date.parse('2012-08-31')
        Date.parse_spec('last_bimonth').should eq Date.parse('2012-05-01')
        Date.parse_spec('last_bimonth', :to).should eq Date.parse('2012-06-30')
      end

      it "should parse relative quarters: this_quarter, last_quarter" do
        Date.parse_spec('this_quarter').should eq Date.parse('2012-07-01')
        Date.parse_spec('this_quarter', :to).should eq Date.parse('2012-09-30')
        Date.parse_spec('last_quarter').should eq Date.parse('2012-04-01')
        Date.parse_spec('last_quarter', :to).should eq Date.parse('2012-06-30')
      end

      it "should parse relative years: this_year, last_year" do
        Date.parse_spec('this_year').should eq Date.parse('2012-01-01')
        Date.parse_spec('this_year', :to).should eq Date.parse('2012-12-31')
        Date.parse_spec('last_year').should eq Date.parse('2011-01-01')
        Date.parse_spec('last_year', :to).should eq Date.parse('2011-12-31')
      end

      it "should parse forever and never" do
        Date.parse_spec('forever').should eq Date::BOT
        Date.parse_spec('forever', :to).should eq Date::EOT
        Date.parse_spec('never').should be_nil
      end
    end

    it "should be able to parse an American-style date" do
      Date.parse_american('2/12/2011').iso.should eq('2011-02-12')
      Date.parse_american('2 / 12/ 2011').iso.should eq('2011-02-12')
      Date.parse_american('2 / 1 / 2011').iso.should eq('2011-02-01')
      Date.parse_american('  2 / 1 / 2011  ').iso.should eq('2011-02-01')
      Date.parse_american('  2 / 1 / 15  ').iso.should eq('2015-02-01')
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
      Date.today.pred.should eq (Date.today - 1)
      Date.today.succ.should eq (Date.today + 1)
    end

    it "should be able to print itself as an American-style date" do
      Date.parse('2011-02-12').american.should eq('2/12/2011')
    end

    it "should be able to print itself in iso form" do
      Date.today.iso.should == '2012-07-18'
    end

    it "should be able to print itself in org form" do
      Date.today.org.should eq('[2012-07-18 Wed]')
      (Date.today + 1.day).org.should eq('[2012-07-19 Thu]')
    end

    it "should be able to print itself in eng form" do
      Date.today.eng.should eq('July 18, 2012')
      (Date.today + 1.day).eng.should eq('July 19, 2012')
    end

    it "should be able to state its quarter" do
      Date.today.quarter.should eq(3)
      Date.parse('2012-02-29').quarter.should eq(1)
      Date.parse('2012-01-01').quarter.should eq(1)
      Date.parse('2012-03-31').quarter.should eq(1)
      Date.parse('2012-04-01').quarter.should eq(2)
      Date.parse('2012-05-15').quarter.should eq(2)
      Date.parse('2012-06-30').quarter.should eq(2)
      Date.parse('2012-07-01').quarter.should eq(3)
      Date.parse('2012-08-15').quarter.should eq(3)
      Date.parse('2012-09-30').quarter.should eq(3)
      Date.parse('2012-10-01').quarter.should eq(4)
      Date.parse('2012-11-15').quarter.should eq(4)
      Date.parse('2012-12-31').quarter.should eq(4)
    end

    it "should know about years" do
      Date.parse('2013-01-01').should be_beginning_of_year
      Date.parse('2013-12-31').should be_end_of_year
      Date.parse('2013-04-01').should_not be_beginning_of_year
      Date.parse('2013-12-30').should_not be_end_of_year
    end

    it "should know about quarters" do
      Date.parse('2013-01-01').should be_beginning_of_quarter
      Date.parse('2013-12-31').should be_end_of_quarter
      Date.parse('2013-04-01').should be_beginning_of_quarter
      Date.parse('2013-06-30').should be_end_of_quarter
      Date.parse('2013-05-01').should_not be_beginning_of_quarter
      Date.parse('2013-07-31').should_not be_end_of_quarter
    end

    it "should know about bimonths" do
      Date.parse('2013-11-04').beginning_of_bimonth.should eq Date.parse('2013-11-01')
      Date.parse('2013-11-04').end_of_bimonth.should eq Date.parse('2013-12-31')
      Date.parse('2013-03-01').should be_beginning_of_bimonth
      Date.parse('2013-04-30').should be_end_of_bimonth
      Date.parse('2013-01-01').should be_beginning_of_bimonth
      Date.parse('2013-12-31').should be_end_of_bimonth
      Date.parse('2013-05-01').should be_beginning_of_bimonth
      Date.parse('2013-06-30').should be_end_of_bimonth
      Date.parse('2013-06-01').should_not be_beginning_of_bimonth
      Date.parse('2013-07-31').should_not be_end_of_bimonth
    end

    it "should know about months" do
      Date.parse('2013-01-01').should be_beginning_of_month
      Date.parse('2013-12-31').should be_end_of_month
      Date.parse('2013-05-01').should be_beginning_of_month
      Date.parse('2013-07-31').should be_end_of_month
      Date.parse('2013-05-02').should_not be_beginning_of_month
      Date.parse('2013-07-30').should_not be_end_of_month
    end

    it "should know about semimonths" do
      Date.parse('2013-11-24').beginning_of_semimonth.should eq Date.parse('2013-11-16')
      Date.parse('2013-11-04').beginning_of_semimonth.should eq Date.parse('2013-11-01')
      Date.parse('2013-11-04').end_of_semimonth.should eq Date.parse('2013-11-15')
      Date.parse('2013-11-24').end_of_semimonth.should eq Date.parse('2013-11-30')
      Date.parse('2013-03-01').should be_beginning_of_semimonth
      Date.parse('2013-03-16').should be_beginning_of_semimonth
      Date.parse('2013-04-15').should be_end_of_semimonth
      Date.parse('2013-04-30').should be_end_of_semimonth
    end

    it "should know about biweeks" do
      Date.parse('2013-11-07').beginning_of_biweek.should eq Date.parse('2013-11-04')
      Date.parse('2013-11-07').end_of_biweek.should eq Date.parse('2013-11-17')
      Date.parse('2013-03-11').should be_beginning_of_biweek
      Date.parse('2013-03-24').should be_end_of_biweek
    end

    it "should know about weeks" do
      Date.parse('2013-11-04').should be_beginning_of_week
      Date.parse('2013-11-10').should be_end_of_week
      Date.parse('2013-12-02').should be_beginning_of_week
      Date.parse('2013-12-08').should be_end_of_week
      Date.parse('2013-10-13').should_not be_beginning_of_week
      Date.parse('2013-10-19').should_not be_end_of_week
    end

    it "should know the beginning of chunks" do
      Date.parse('2013-11-04').beginning_of_chunk(:year).should eq Date.parse('2013-01-01')
      Date.parse('2013-11-04').beginning_of_chunk(:quarter).should eq Date.parse('2013-10-01')
      Date.parse('2013-12-04').beginning_of_chunk(:bimonth).should eq Date.parse('2013-11-01')
      Date.parse('2013-11-04').beginning_of_chunk(:month).should eq Date.parse('2013-11-01')
      Date.parse('2013-11-04').beginning_of_chunk(:semimonth).should eq Date.parse('2013-11-01')
      Date.parse('2013-11-24').beginning_of_chunk(:semimonth).should eq Date.parse('2013-11-16')
      Date.parse('2013-11-08').beginning_of_chunk(:biweek).should eq Date.parse('2013-11-04')
      Date.parse('2013-11-08').beginning_of_chunk(:week).should eq Date.parse('2013-11-04')
      expect {
        Date.parse('2013-11-04').beginning_of_chunk(:wek)
      }.to raise_error
    end

    it "should know the end of chunks" do
      Date.parse('2013-07-04').end_of_chunk(:year).should eq Date.parse('2013-12-31')
      Date.parse('2013-07-04').end_of_chunk(:quarter).should eq Date.parse('2013-09-30')
      Date.parse('2013-12-04').end_of_chunk(:bimonth).should eq Date.parse('2013-12-31')
      Date.parse('2013-07-04').end_of_chunk(:month).should eq Date.parse('2013-07-31')
      Date.parse('2013-11-04').end_of_chunk(:semimonth).should eq Date.parse('2013-11-15')
      Date.parse('2013-11-24').end_of_chunk(:semimonth).should eq Date.parse('2013-11-30')
      Date.parse('2013-11-08').end_of_chunk(:biweek).should eq Date.parse('2013-11-17')
      Date.parse('2013-07-04').end_of_chunk(:week).should eq Date.parse('2013-07-07')
      expect {
        Date.parse('2013-11-04').end_of_chunk(:wek)
      }.to raise_error
    end

    it "should know how to expand to chunk periods" do
      Date.parse('2013-07-04').expand_to_period(:year).
        should eq Period.new(Date.parse('2013-01-01'), Date.parse('2013-12-31'))
      Date.parse('2013-07-04').expand_to_period(:quarter).
        should eq Period.new(Date.parse('2013-07-01'), Date.parse('2013-09-30'))
      Date.parse('2013-07-04').expand_to_period(:bimonth).
        should eq Period.new(Date.parse('2013-07-01'), Date.parse('2013-08-31'))
      Date.parse('2013-07-04').expand_to_period(:month).
        should eq Period.new(Date.parse('2013-07-01'), Date.parse('2013-07-31'))
      Date.parse('2013-07-04').expand_to_period(:semimonth).
        should eq Period.new(Date.parse('2013-07-01'), Date.parse('2013-07-15'))
      Date.parse('2013-07-04').expand_to_period(:biweek).
        should eq Period.new(Date.parse('2013-07-01'), Date.parse('2013-07-14'))
      Date.parse('2013-07-04').expand_to_period(:week).
        should eq Period.new(Date.parse('2013-07-01'), Date.parse('2013-07-07'))
      Date.parse('2013-07-04').expand_to_period(:day).
        should eq Period.new(Date.parse('2013-07-04'), Date.parse('2013-07-04'))
    end
  end
end
