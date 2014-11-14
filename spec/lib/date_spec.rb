# coding: utf-8
require 'spec_helper'

describe Date do
  before :each do
    # Pretend it is this date. Not at beg or end of year, quarter,
    # month, or week.  It is a Wednesday
    allow(Date).to receive_messages(:today => Date.parse('2012-07-18'))
    allow(Date).to receive_messages(:current => Date.parse('2012-07-18'))
  end

  describe "class methods" do
    describe "date arithmetic" do
      it "should know the number of days in a month" do
        expect(Date.days_in_month(2000, 1)).to eq 31
        expect(Date.days_in_month(1900, 2)).to eq 28
        expect(Date.days_in_month(2000, 2)).to eq 29
        expect(Date.days_in_month(2001, 2)).to eq 28
        expect(Date.days_in_month(2004, 2)).to eq 29
        expect(Date.days_in_month(2004, 3)).to eq 31
        expect(Date.days_in_month(2004, 4)).to eq 30
        expect(Date.days_in_month(2004, 5)).to eq 31
        expect(Date.days_in_month(2004, 6)).to eq 30
        expect(Date.days_in_month(2004, 7)).to eq 31
        expect(Date.days_in_month(2004, 8)).to eq 31
        expect(Date.days_in_month(2004, 9)).to eq 30
        expect(Date.days_in_month(2004, 10)).to eq 31
        expect(Date.days_in_month(2004, 11)).to eq 30
        expect(Date.days_in_month(2004, 12)).to eq 31
        expect { Date.days_in_month(2004, 13) }.to raise_error ArgumentError
      end

      it "should know the nth weekday in a year, month" do
        # Sunday is 0, Saturday is 6
        #     January 2014
        # Su Mo Tu We Th Fr Sa
        #           1  2  3  4
        #  5  6  7  8  9 10 11
        # 12 13 14 15 16 17 18
        # 19 20 21 22 23 24 25
        # 26 27 28 29 30 31

        # First Monday
        expect(Date.nth_wday_in_year_month(1, 1, 2014, 1))
          .to eq Date.parse('2014-01-06')
        # Second Monday
        expect(Date.nth_wday_in_year_month(2, 1, 2014, 1))
          .to eq Date.parse('2014-01-13')
        # Third Sunday
        expect(Date.nth_wday_in_year_month(3, 0, 2014, 1))
          .to eq Date.parse('2014-01-19')
        # Third Sunday (float floored)
        expect(Date.nth_wday_in_year_month(3.2, 0, 2014, 1))
          .to eq Date.parse('2014-01-19')
        # Negative wday counts from end: Last Sunday
        expect(Date.nth_wday_in_year_month(-1, 0, 2014, 1))
          .to eq Date.parse('2014-01-26')
        expect(Date.nth_wday_in_year_month(-3, 0, 2014, 1))
          .to eq Date.parse('2014-01-12')
        # Negative wday counts from end: Last Thursday
        expect(Date.nth_wday_in_year_month(-1, 4, 2014, 1))
          .to eq Date.parse('2014-01-30')

        # Exceptions
        expect {
          # N is zero
          Date.nth_wday_in_year_month(0, 6, 2014, 1)
        }.to raise_error ArgumentError
        expect {
          # Wday too big
          Date.nth_wday_in_year_month(3, 7, 2014, 1)
        }.to raise_error ArgumentError
        expect {
          # Month too big
          Date.nth_wday_in_year_month(3, 1, 2014, 13)
        }.to raise_error ArgumentError
      end

      it "should know Easter for a given year" do
        # Grabbed these dates of Easter from
        # http://tlarsen2.tripod.com/thomaslarsen/easterdates.html
        easters = {
          2000 => '2000-04-23',
          2001 => '2001-04-15',
          2002 => '2002-03-31',
          2003 => '2003-04-20',
          2004 => '2004-04-11',
          2005 => '2005-03-27',
          2006 => '2006-04-16',
          2007 => '2007-04-08',
          2008 => '2008-03-23',
          2009 => '2009-04-12',
          2010 => '2010-04-04',
          2011 => '2011-04-24',
          2012 => '2012-04-08',
          2013 => '2013-03-31',
          2014 => '2014-04-20',
          2015 => '2015-04-05',
          2016 => '2016-03-27',
          2017 => '2017-04-16',
          2018 => '2018-04-01',
          2019 => '2019-04-21',
          2020 => '2020-04-12',
          2021 => '2021-04-04',
          2022 => '2022-04-17',
          2023 => '2023-04-09',
          2024 => '2024-03-31',
          2025 => '2025-04-20',
          2026 => '2026-04-05',
          2027 => '2027-03-28',
          2028 => '2028-04-16',
          2029 => '2029-04-01',
          2030 => '2030-04-21',
          2031 => '2031-04-13',
          2032 => '2032-03-28',
          2033 => '2033-04-17',
          2034 => '2034-04-09',
          2035 => '2035-03-25',
          2036 => '2036-04-13',
          2037 => '2037-04-05',
          2038 => '2038-04-25',
          2039 => '2039-04-10',
          2040 => '2040-04-01',
          2041 => '2041-04-21',
          2042 => '2042-04-06',
          2043 => '2043-03-29',
          2044 => '2044-04-17',
          2045 => '2045-04-09',
          2046 => '2046-03-25',
          2047 => '2047-04-14',
          2048 => '2048-04-05',
          2049 => '2049-04-18',
          2050 => '2050-04-10',
          2051 => '2051-04-02',
          2052 => '2052-04-21',
          2053 => '2053-04-06',
          2054 => '2054-03-29',
          2055 => '2055-04-18',
          2056 => '2056-04-02',
          2057 => '2057-04-22',
          2058 => '2058-04-14',
          2059 => '2059-03-30',
          2060 => '2060-04-18',
          2061 => '2061-04-10',
          2062 => '2062-03-26',
          2063 => '2063-04-15',
          2064 => '2064-04-06',
          2065 => '2065-03-29',
          2066 => '2066-04-11',
          2067 => '2067-04-03',
          2068 => '2068-04-22',
          2069 => '2069-04-14',
          2070 => '2070-03-30',
          2071 => '2071-04-19',
          2072 => '2072-04-10',
          2073 => '2073-03-26',
          2074 => '2074-04-15',
          2075 => '2075-04-07',
          2076 => '2076-04-19',
          2077 => '2077-04-11',
          2078 => '2078-04-03',
          2079 => '2079-04-23',
          2080 => '2080-04-07',
          2081 => '2081-03-30',
          2082 => '2082-04-19',
          2083 => '2083-04-04',
          2084 => '2084-03-26',
          2085 => '2085-04-15',
          2086 => '2086-03-31',
          2087 => '2087-04-20',
          2088 => '2088-04-11',
          2089 => '2089-04-03',
          2090 => '2090-04-16',
          2091 => '2091-04-08',
          2092 => '2092-03-30',
          2093 => '2093-04-12',
          2094 => '2094-04-04',
          2095 => '2095-04-24',
          2096 => '2096-04-15',
          2097 => '2097-03-31',
          2098 => '2098-04-20',
          2099 => '2099-04-12',
        }
        easters.each_pair do |year, date|
          expect(Date.easter(year)).to eq Date.parse(date)
        end
      end
    end

    describe "parsing" do
      it "should be able to parse an American-style date" do
        expect(Date.parse_american('2/12/2011').iso).to eq('2011-02-12')
        expect(Date.parse_american('2 / 12/ 2011').iso).to eq('2011-02-12')
        expect(Date.parse_american('2 / 1 / 2011').iso).to eq('2011-02-01')
        expect(Date.parse_american('  2 / 1 / 2011  ').iso).to eq('2011-02-01')
        expect(Date.parse_american('  2 / 1 / 15  ').iso).to eq('2015-02-01')
        expect {
          Date.parse_american('xx/1/15')
        }.to raise_error ArgumentError
      end
    end

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
  end

  describe "instance methods" do
    describe "print as string" do
      it "should be able to print itself as an American-style date" do
        expect(Date.parse('2011-02-12').american).to eq('2/12/2011')
      end

      it "should be able to print itself in iso form" do
        expect(Date.today.iso).to eq '2012-07-18'
      end

      it "should be able to print itself in tex_quote form" do
        expect(Date.today.tex_quote).to eq '2012-07-18'
      end

      it "should be able to print itself in org form" do
        expect(Date.today.org).to eq('[2012-07-18 Wed]')
        expect((Date.today + 1.day).org).to eq('[2012-07-19 Thu]')
      end

      it "should be able to print itself in eng form" do
        expect(Date.today.eng).to eq('July 18, 2012')
        expect((Date.today + 1.day).eng).to eq('July 19, 2012')
      end

      it "should be able to print itself in numeric form" do
        expect(Date.today.num).to eq('20120718')
        expect((Date.today + 1.day).num).to eq('20120719')
      end
    end

    describe "date arithmetic" do
      it "should know if its the nth weekday in a given month" do
        expect(Date.parse('2014-11-13').nth_wday_in_month?(2, 4, 11)).
          to be true
        expect(Date.parse('2014-11-13').nth_wday_in_month?(-3, 4, 11)).
          to be true
        expect(Date.parse('2014-11-13').nth_wday_in_month?(2, 4, 10)).
          to be false
      end

      it "should know if its a weekend or a weekday" do
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

      it "should be able to add a chuck sym to itself" do
        # Date.today is '2012-07-18'
        expect(Date.today.add_chunk(:year)).to eq(Date.parse('2013-07-18'))
        expect(Date.today.add_chunk(:quarter)).to eq(Date.parse('2012-10-18'))
        expect(Date.today.add_chunk(:bimonth)).to eq(Date.parse('2012-09-18'))
        expect(Date.today.add_chunk(:month)).to eq(Date.parse('2012-08-18'))
        expect(Date.today.add_chunk(:semimonth)).to eq(Date.parse('2012-08-02'))
        expect(Date.today.add_chunk(:biweek)).to eq(Date.parse('2012-08-01'))
        expect(Date.today.add_chunk(:week)).to eq(Date.parse('2012-07-25'))
        expect(Date.today.add_chunk(:day)).
          to eq(Date.parse('2012-07-19'))
        expect {
          Date.today.add_chunk(:hour)
        }.to raise_error ArgumentError
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

      it "should know if it's within 6 months of another date" do
        # This uses Section 16's logic that one date is "within a
        # period of less than six months" of another date only if it
        # is within the date six months minus 2 days away from the
        # current date.
        expect(Date.parse('2014-01-12'))
          .to be_within_6mos_of(Date.parse('2014-06-12'))
        expect(Date.parse('2014-01-12'))
          .not_to be_within_6mos_of(Date.parse('2014-07-12'))
        expect(Date.parse('2014-01-12'))
          .not_to be_within_6mos_of(Date.parse('2014-07-11'))
        expect(Date.parse('2014-01-12'))
          .to be_within_6mos_of(Date.parse('2014-07-10'))
      end
    end

    describe "holidays" do
      it "should know Easter in its year" do
        expect(Date.today.easter_this_year).to eq(Date.parse('2012-04-08'))
        expect(Date.parse('2014-04-20').easter?).to be true
        expect(Date.parse('2014-03-20').easter?).to be false
      end

      it "should know if its a federal holiday" do
        # Got these from:
        # http://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/

        # For 2011:
        # Friday, December 31, 2010 *   New Year's Day
        # Monday, January 17  Birthday of Martin Luther King, Jr.
        # Monday, February 21 **  Washington's Birthday
        # Monday, May 30  Memorial Day
        # Monday, July 4  Independence Day
        # Monday, September 5   Labor Day
        # Monday, October 10  Columbus Day
        # Friday, November 11   Veterans Day
        # Thursday, November 24   Thanksgiving Day
        # Tuesday, December 26 ***  Christmas Day
        expect(Date.parse('2010-12-31')).to be_fed_holiday
        expect(Date.parse('2011-01-17')).to be_fed_holiday
        expect(Date.parse('2011-02-21')).to be_fed_holiday
        expect(Date.parse('2011-05-30')).to be_fed_holiday
        expect(Date.parse('2011-07-04')).to be_fed_holiday
        expect(Date.parse('2011-09-05')).to be_fed_holiday
        expect(Date.parse('2011-10-10')).to be_fed_holiday
        expect(Date.parse('2011-11-11')).to be_fed_holiday
        expect(Date.parse('2011-11-24')).to be_fed_holiday
        expect(Date.parse('2011-12-26')).to be_fed_holiday

        # For 2014:
        # Wednesday, January 1  New Year’s Day
        # Monday, January 20  Birthday of Martin Luther King, Jr.
        # Monday, February 17 Washington’s Birthday
        # Monday, May 26  Memorial Day
        # Friday, July 4  Independence Day
        # Monday, September 1   Labor Day
        # Monday, October 13  Columbus Day
        # Tuesday, November 11  Veterans Day
        # Thursday, November 27   Thanksgiving Day
        # Thursday, December 25   Christmas Day
        expect(Date.parse('2014-01-01')).to be_fed_holiday
        expect(Date.parse('2014-01-20')).to be_fed_holiday
        expect(Date.parse('2014-02-17')).to be_fed_holiday
        expect(Date.parse('2014-05-26')).to be_fed_holiday
        expect(Date.parse('2014-07-04')).to be_fed_holiday
        expect(Date.parse('2014-09-01')).to be_fed_holiday
        expect(Date.parse('2014-10-13')).to be_fed_holiday
        expect(Date.parse('2014-11-11')).to be_fed_holiday
        expect(Date.parse('2014-11-27')).to be_fed_holiday
        expect(Date.parse('2014-12-25')).to be_fed_holiday
        # Not holidays
        expect(Date.parse('2014-02-14')).not_to be_fed_holiday
        expect(Date.parse('2014-04-18')).not_to be_fed_holiday

        # For 2017:
        # Monday, January 2  New Year’s Day
        # Monday, January 16  Birthday of Martin Luther King, Jr.
        # Monday, February 20   Washington’s Birthday
        # Monday, May 29  Memorial Day
        # Tuesday, July 4   Independence Day
        # Monday, September 4   Labor Day
        # Monday, October 9   Columbus Day
        # Friday, November 10  Veterans Day
        # Thursday, November 23   Thanksgiving Day
        # Monday, December 25   Christmas Day
        expect(Date.parse('2017-01-02')).to be_fed_holiday
        expect(Date.parse('2017-01-16')).to be_fed_holiday
        expect(Date.parse('2017-02-20')).to be_fed_holiday
        expect(Date.parse('2017-05-29')).to be_fed_holiday
        expect(Date.parse('2017-07-04')).to be_fed_holiday
        expect(Date.parse('2017-09-04')).to be_fed_holiday
        expect(Date.parse('2017-10-09')).to be_fed_holiday
        expect(Date.parse('2017-11-10')).to be_fed_holiday
        expect(Date.parse('2017-11-23')).to be_fed_holiday
        expect(Date.parse('2017-12-25')).to be_fed_holiday

        # 2003 and 2008 had Christmas on Thur and this apparently makes
        # the following Friday a holiday.  I can't find any authority
        # for this, but the government appeared to be shut down on these
        # days.
        expect(Date.parse('2003-12-26')).to be_fed_holiday
        expect(Date.parse('2008-12-26')).to be_fed_holiday

        # Some non-holidays
        # New Year's Eve is /not/ a holiday unless on a weekend
        # New Year's Eve on a Thursday
        expect(Date.parse('2015-12-31')).not_to be_fed_holiday
        # New Year's Eve on a Saturday
        expect(Date.parse('2016-12-31')).to be_fed_holiday
        # Monday
        expect(Date.parse('2014-11-17')).not_to be_fed_holiday
        # Tuesday
        expect(Date.parse('2014-11-18')).not_to be_fed_holiday
        # Wednesday
        expect(Date.parse('2014-11-19')).not_to be_fed_holiday
        # Thursday
        expect(Date.parse('2014-11-20')).not_to be_fed_holiday
        # Friday
        expect(Date.parse('2014-11-21')).not_to be_fed_holiday

        # Weekends are holidays, regardless
        expect(Date.parse('2014-11-22')).to be_fed_holiday
        expect(Date.parse('2014-11-23')).to be_fed_holiday
      end

      it "should know if its an NYSE holiday" do
        #################  2014         2015       2016
        # New Year’s Day  January 1   January 1   January 1
        # Martin Luther King, Jr. Day   January 20  January 19  January 18
        # Washington’s Birthday   February 17   February 16   February 15
        # Good Friday   April 18  April 3   March 25
        # Memorial Day  May 26  May 25  May 30
        # Independence Day  July 4  July 3  July 4
        # Labor Day   September 1   September 7   September 5
        # Thanksgiving Day  November 27   November 26   November 24
        # Christmas Day   December 25   December 25   December 26
        expect(Date.parse('2014-01-01')).to be_nyse_holiday
        expect(Date.parse('2014-01-20')).to be_nyse_holiday
        expect(Date.parse('2014-02-17')).to be_nyse_holiday
        expect(Date.parse('2014-04-18')).to be_nyse_holiday
        expect(Date.parse('2014-05-26')).to be_nyse_holiday
        expect(Date.parse('2014-07-04')).to be_nyse_holiday
        expect(Date.parse('2014-09-01')).to be_nyse_holiday
        expect(Date.parse('2014-10-13')).not_to be_nyse_holiday
        expect(Date.parse('2014-11-11')).not_to be_nyse_holiday
        expect(Date.parse('2014-11-27')).to be_nyse_holiday
        expect(Date.parse('2014-12-25')).to be_nyse_holiday

        expect(Date.parse('2015-01-01')).to be_nyse_holiday
        expect(Date.parse('2015-01-19')).to be_nyse_holiday
        expect(Date.parse('2015-02-16')).to be_nyse_holiday
        expect(Date.parse('2015-04-03')).to be_nyse_holiday
        expect(Date.parse('2015-05-25')).to be_nyse_holiday
        expect(Date.parse('2015-07-03')).to be_nyse_holiday
        expect(Date.parse('2015-09-07')).to be_nyse_holiday
        expect(Date.parse('2015-10-13')).not_to be_nyse_holiday
        expect(Date.parse('2015-11-11')).not_to be_nyse_holiday
        expect(Date.parse('2015-11-26')).to be_nyse_holiday
        expect(Date.parse('2015-12-25')).to be_nyse_holiday

        expect(Date.parse('2016-01-01')).to be_nyse_holiday
        expect(Date.parse('2016-01-18')).to be_nyse_holiday
        expect(Date.parse('2016-02-15')).to be_nyse_holiday
        expect(Date.parse('2016-03-25')).to be_nyse_holiday
        expect(Date.parse('2016-05-30')).to be_nyse_holiday
        expect(Date.parse('2016-07-04')).to be_nyse_holiday
        expect(Date.parse('2016-09-05')).to be_nyse_holiday
        expect(Date.parse('2016-10-13')).not_to be_nyse_holiday
        expect(Date.parse('2016-11-11')).not_to be_nyse_holiday
        expect(Date.parse('2016-11-26')).to be_nyse_holiday
        expect(Date.parse('2016-12-26')).to be_nyse_holiday

        # Some non-holidays
        # Monday
        expect(Date.parse('2014-11-17')).not_to be_nyse_holiday
        # Tuesday
        expect(Date.parse('2014-11-18')).not_to be_nyse_holiday
        # Wednesday
        expect(Date.parse('2014-11-19')).not_to be_nyse_holiday
        # Thursday
        expect(Date.parse('2014-11-20')).not_to be_nyse_holiday
        # Friday
        expect(Date.parse('2014-11-21')).not_to be_nyse_holiday

        # Weekends are holidays, regardless
        expect(Date.parse('2014-11-22')).to be_nyse_holiday
        expect(Date.parse('2014-11-23')).to be_nyse_holiday
      end

      it "should know if it is a Federal workday" do
        # Some holidays
        expect(Date.parse('2017-02-20')).not_to be_fed_workday
        expect(Date.parse('2017-05-29')).not_to be_fed_workday
        expect(Date.parse('2017-07-04')).not_to be_fed_workday

        # Some non-holidays
        # Monday
        expect(Date.parse('2014-11-17')).to be_fed_workday
        # Tuesday
        expect(Date.parse('2014-11-18')).to be_fed_workday
        # Wednesday
        expect(Date.parse('2014-11-19')).to be_fed_workday
        # Thursday
        expect(Date.parse('2014-11-20')).to be_fed_workday
        # Friday
        expect(Date.parse('2014-11-21')).to be_fed_workday

        # Weekends are holidays, regardless
        expect(Date.parse('2014-11-22')).not_to be_fed_workday
        expect(Date.parse('2014-11-23')).not_to be_fed_workday
      end

      it "should know if it is an NYSE workday" do
        # Some holidays
        expect(Date.parse('2016-01-01')).not_to be_nyse_workday
        expect(Date.parse('2016-01-18')).not_to be_nyse_workday
        expect(Date.parse('2016-02-15')).not_to be_nyse_workday

        # Some non-holidays
        # Monday
        expect(Date.parse('2014-11-17')).to be_nyse_workday
        # Tuesday
        expect(Date.parse('2014-11-18')).to be_nyse_workday
        # Wednesday
        expect(Date.parse('2014-11-19')).to be_nyse_workday
        # Thursday
        expect(Date.parse('2014-11-20')).to be_nyse_workday
        # Friday
        expect(Date.parse('2014-11-21')).to be_nyse_workday

        # Weekends are holidays, regardless
        expect(Date.parse('2014-11-22')).not_to be_nyse_workday
        expect(Date.parse('2014-11-23')).not_to be_nyse_workday
      end

      it "should know the next federal workday" do
        expect(Date.parse('2015-12-31').next_fed_workday)
          .to eq Date.parse('2016-01-04')
        expect(Date.parse('2016-04-20').next_fed_workday)
          .to eq Date.parse('2016-04-21')
        expect(Date.parse('2016-04-22').next_fed_workday)
          .to eq Date.parse('2016-04-25')
      end

      it "should know the prior federal workday" do
        expect(Date.parse('2016-01-04').prior_fed_workday)
          .to eq Date.parse('2015-12-31')
        expect(Date.parse('2016-04-21').prior_fed_workday)
          .to eq Date.parse('2016-04-20')
        expect(Date.parse('2016-04-25').prior_fed_workday)
          .to eq Date.parse('2016-04-22')
      end

      it "should know the next NYSE workday" do
        expect(Date.parse('2015-12-31').next_nyse_workday)
          .to eq Date.parse('2016-01-04')
        expect(Date.parse('2016-04-20').next_nyse_workday)
          .to eq Date.parse('2016-04-21')
        expect(Date.parse('2016-04-22').next_nyse_workday)
          .to eq Date.parse('2016-04-25')
      end

      it "should know the prior NYSE workday" do
        # The Monday after Easter; go to prior Thur since Good Friday
        # is an NYSE holiday.
        expect(Date.parse('2014-04-21').prior_nyse_workday)
          .to eq Date.parse('2014-04-17')
        expect(Date.parse('2016-01-04').prior_nyse_workday)
          .to eq Date.parse('2015-12-31')
        expect(Date.parse('2016-04-21').prior_nyse_workday)
          .to eq Date.parse('2016-04-20')
        expect(Date.parse('2016-04-25').prior_nyse_workday)
          .to eq Date.parse('2016-04-22')
      end
    end
  end
end
