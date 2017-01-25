require 'spec_helper'

module FatCore
  describe Table do
    before :all do
      @csv_file_body = <<-EOS
Ref,Date,Code,RawShares,Shares,Price,Info
1,2006-05-02,P,5000,5000,8.6000,2006-08-09-1-I
2,2006-05-03,P,5000,5000,8.4200,2006-08-09-1-I
3,2006-05-04,P,5000,5000,8.4000,2006-08-09-1-I
4,2006-05-10,P,8600,8600,8.0200,2006-08-09-1-D
5,2006-05-12,P,10000,10000,7.2500,2006-08-09-1-D
6,2006-05-12,P,2000,2000,6.7400,2006-08-09-1-I
7,2006-05-16,P,5000,5000,7.0000,2006-08-09-1-D
8,2006-05-17,P,5000,5000,6.7000,2006-08-09-1-D
9,2006-05-17,P,2000,2000,6.7400,2006-08-09-1-I
10,2006-05-19,P,1000,1000,7.2500,2006-08-09-1-I
11,2006-05-19,P,1000,1000,7.2500,2006-08-09-1-I
12,2006-05-31,P,2000,2000,7.9200,2006-08-09-1-I
13,2006-06-05,P,1000,1000,7.9200,2006-08-09-1-I
14,2006-06-15,P,5000,5000,6.9800,2006-08-09-1-I
15,2006-06-16,P,1000,1000,6.9300,2006-08-09-1-I
16,2006-06-16,P,1000,1000,6.9400,2006-08-09-1-I
17,2006-06-29,P,4000,4000,7.0000,2006-08-09-1-I
18,2006-07-14,P,2000,2000,6.2000,2006-08-09-1-D
19,2006-08-03,P,1400,1400,4.3900,2006-08-09-1-D
20,2006-08-07,P,1100,1100,4.5900,2006-08-09-1-D
21,2006-08-08,P,16000,16000,4.7000,2006-08-21-1-D
22,2006-08-08,S,16000,16000,4.7000,2006-08-21-1-I
23,2006-08-15,P,16000,16000,4.8000,2006-08-21-1-D
24,2006-08-15,S,16000,16000,4.8000,2006-08-21-1-I
25,2006-08-16,P,2100,2100,5.2900,2006-08-21-1-I
26,2006-08-17,P,2900,2900,5.7000,2006-08-21-1-I
27,2006-08-23,P,8000,8000,5.2400,2006-08-25-1-D
28,2006-08-23,S,8000,8000,5.2400,2006-08-29-1-I
29,2006-08-28,P,1000,1000,5.4000,2006-08-29-1-D
30,2006-08-29,P,2000,2000,5.4000,2006-08-30-1-D
31,2006-08-29,S,2000,2000,5.4000,2006-08-30-1-I
32,2006-09-05,P,2700,2700,5.7500,2006-09-06-1-I
33,2006-09-11,P,4000,4000,5.7200,2006-09-15-1-D
34,2006-09-11,S,4000,4000,5.7200,2006-09-15-1-I
35,2006-09-12,P,3000,3000,5.4800,2006-09-15-2-I
36,2006-09-13,P,1700,1700,5.4100,2006-09-15-2-I
37,2006-09-20,P,7500,7500,5.4900,2006-09-21-1-I
38,2006-12-07,S,6000,6000,7.8900,2006-12-11-1-I
39,2006-12-11,S,100,100,8.0000,2006-12-11-1-I
40,2007-01-29,P,2500,2500,12.1000,2007-04-27-1-I
41,2007-01-31,P,2500,2500,13.7000,2007-04-27-1-I
42,2007-02-02,P,4000,4000,15.1500,2007-04-27-1-I
43,2007-02-06,P,5000,5000,14.9500,2007-04-27-1-I
44,2007-02-07,P,400,400,15.0000,2007-04-27-1-I
45,2007-02-08,P,4600,4600,15.0000,2007-04-27-1-I
46,2007-02-12,P,3500,3500,14.9100,2007-04-27-1-I
47,2007-02-13,P,1500,1500,14.6500,2007-04-27-1-D
48,2007-02-14,P,2000,2000,14.4900,2007-04-27-1-D
49,2007-02-15,P,3000,3000,14.3000,2007-04-27-1-I
50,2007-02-21,P,8500,8500,14.6500,2007-04-27-1-D
51,2007-02-21,S,8500,8500,14.6500,2007-04-27-1-I
52,2007-02-22,P,1500,1500,14.8800,2007-04-27-1-I
53,2007-02-23,P,3000,3000,14.9700,2007-04-27-1-I
54,2007-02-23,P,5000,5000,14.9700,2007-04-27-1-I
55,2007-02-27,P,5200,5200,13.8800,2007-04-27-1-I
56,2007-02-28,P,6700,6700,13.0000,2007-04-27-1-D
57,2007-02-28,P,800,800,13.0000,2007-04-27-1-I
58,2007-02-28,P,8400,8400,13.0000,2007-04-27-1-I
59,2007-03-01,P,2500,2500,12.2500,2007-04-27-1-D
60,2007-03-05,P,1800,1800,11.9700,2007-04-27-1-D
61,2007-03-06,P,500,500,12.1300,2007-04-27-1-D
62,2007-03-07,P,3000,3000,12.3700,2007-04-27-1-D
63,2007-03-08,P,2000,2000,12.6000,2007-04-27-1-I
64,2007-03-09,P,7700,7700,12.8100,2007-04-27-1-I
65,2007-03-12,P,4200,4200,12.4600,2007-04-27-1-I
66,2007-03-13,P,800,800,12.2500,2007-04-27-1-I
67,2007-03-19,P,2000,2000,14.5500,2007-04-27-2-I
68,2007-03-19,P,5000,5000,14.5500,2007-04-27-2-I
69,2007-03-19,P,2000,2000,14.3300,2007-04-27-2-I
70,2007-03-20,P,1000,1000,14.4600,2007-04-27-2-I
71,2007-03-20,P,1500,1500,14.4600,2007-04-27-2-I
72,2007-03-21,P,3900,3900,16.9000,2007-04-27-2-I
73,2007-03-23,P,8000,8000,14.9700,2007-04-27-1-D
74,2007-03-27,P,1000,1000,16.9300,2007-04-27-2-I
75,2007-03-28,P,1000,1000,16.5000,2007-04-27-2-D
76,2007-03-29,P,1000,1000,16.2500,2007-04-27-2-D
77,2007-04-04,P,200,200,17.8600,2007-04-27-2-I
78,2007-04-04,P,2000,2000,19.5000,2007-04-27-2-I
79,2007-04-04,P,3000,3000,19.1300,2007-04-27-2-I
80,2007-04-05,P,1000,1000,19.1500,2007-04-27-2-I
81,2007-04-10,P,2000,2000,20.7500,2007-04-27-2-I
82,2007-04-11,P,1000,1000,20.5000,2007-04-27-2-I
83,2007-04-12,P,600,600,21.5000,2007-04-27-2-I
84,2007-04-12,P,1000,1000,21.4500,2007-04-27-2-I
85,2007-04-13,P,2100,2100,21.5000,2007-04-27-2-I
86,2007-04-16,P,500,500,22.6000,2007-04-27-2-I
87,2007-04-17,P,3500,3500,23.5500,2007-04-27-2-D
88,2007-04-17,S,3500,3500,23.5500,2007-04-27-2-I
89,2007-04-23,P,5000,5000,23.4500,2007-04-27-2-I
90,2007-04-24,P,5000,5000,24.3000,2007-04-27-2-I
91,2007-04-25,S,10000,10000,25.7000,2007-04-27-2-I
EOS

      @org_file_body = <<-EOS

* Morgan Transactions
:PROPERTIES:
:TABLE_EXPORT_FILE: morgan.csv
:END:

#+TBLNAME: morgan_tab
| Ref |       Date | Code |     Raw | Shares |    Price | Info   |
|-----+------------+------+---------+--------+----------+--------|
|  29 | 2013-05-02 | P    | 795,546 |  2,609 |  1.18500 | ZMPEF1 |
|  30 | 2013-05-02 | P    | 118,186 |    388 | 11.85000 | ZMPEF1 |
|  31 | 2013-05-02 | P    | 340,948 |  1,926 |  1.18500 | ZMPEF2 |
|  32 | 2013-05-02 | P    |  50,651 |    286 | 11.85000 | ZMPEF2 |
|  33 | 2013-05-20 | S    |  12,000 |     32 | 28.28040 | ZMEAC  |
|  34 | 2013-05-20 | S    |  85,000 |    226 | 28.32240 | ZMEAC  |
|  35 | 2013-05-20 | S    |  33,302 |     88 | 28.63830 | ZMEAC  |
|  36 | 2013-05-23 | S    |   8,000 |     21 | 27.10830 | ZMEAC  |
|  37 | 2013-05-23 | S    |  23,054 |     61 | 26.80150 | ZMEAC  |
|  38 | 2013-05-23 | S    |  39,906 |    106 | 25.17490 | ZMEAC  |
|  39 | 2013-05-29 | S    |  13,459 |     36 | 24.74640 | ZMEAC  |
|  40 | 2013-05-29 | S    |  15,700 |     42 | 24.77900 | ZMEAC  |
|  41 | 2013-05-29 | S    |  15,900 |     42 | 24.58020 | ZMEAC  |
|  42 | 2013-05-30 | S    |   6,679 |     18 | 25.04710 | ZMEAC  |

* Another Heading
EOS
    end

    describe 'construction' do
      it 'should be create-able from a CSV IO object' do
        tab = Table.new(StringIO.new(@csv_file_body), '.csv')
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to be > 20
        expect(tab.headers.sort)
          .to eq [:code, :date, :info, :price, :rawshares, :ref, :shares]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:code].class).to eq String
          expect(row[:date].class).to eq Date
          expect(row[:shares].is_a?(Numeric)).to be true
          unless row[:rawshares].nil?
            expect(row[:rawshares].is_a?(Numeric)).to be true
          end
          expect(row[:price].is_a?(Numeric)).to be true
          expect([Numeric, String].any? { |t| row[:ref].is_a?(t) }).to be true
        end
      end

      it 'should be create-able from an Org IO object' do
        tab = Table.new(StringIO.new(@org_file_body), '.org')
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to be > 10
        expect(tab.headers.sort)
          .to eq [:code, :date, :info, :price, :raw, :ref, :shares]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:code].class).to eq String
          expect(row[:date].class).to eq Date
          expect(row[:shares].is_a?(Numeric)).to be true
          unless row[:rawshares].nil?
            expect(row[:rawshares].is_a?(Numeric)).to be true
          end
          expect(row[:price].is_a?(BigDecimal)).to be true
          expect([Numeric, String].any? { |t| row[:ref].is_a?(t) }).to be true
          expect(row[:info].class).to eq String
        end
      end

      it 'should be create-able from a CSV file' do
        File.open('/tmp/junk.csv', 'w') { |f| f.write(@csv_file_body) }
        tab = Table.new('/tmp/junk.csv')
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to be > 20
        expect(tab.headers.sort)
          .to eq [:code, :date, :info, :price, :rawshares, :ref, :shares]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:code].class).to eq String
          expect(row[:date].class).to eq Date
          expect(row[:shares].is_a?(Numeric)).to be true
          unless row[:rawshares].nil?
            expect(row[:rawshares].is_a?(Numeric)).to be true
          end
          expect(row[:price].is_a?(BigDecimal)).to be true
          expect([Numeric, String].any? { |t| row[:ref].is_a?(t) }).to be true
          expect(row[:info].class).to eq Date
        end
      end

      it 'should be create-able from an Org IO object' do
        File.open('/tmp/junk.org', 'w') { |f| f.write(@org_file_body) }
        tab = Table.new('/tmp/junk.org')
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to be > 10
        expect(tab.rows[0].keys.sort)
          .to eq [:code, :date, :info, :price, :raw, :ref, :shares]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:code].class).to eq String
          expect(row[:date].class).to eq Date
          expect(row[:shares].is_a?(Numeric)).to be true
          unless row[:rawshares].nil?
            expect(row[:rawshares].is_a?(Numeric)).to be true
          end
          expect(row[:price].is_a?(BigDecimal)).to be true
          expect([Numeric, String].any? { |t| row[:ref].is_a?(t) }).to be true
          expect(row[:info].class).to eq String
        end
      end

      it 'should be create-able from an Array of Arrays with header and hrule' do
        # rubocop:disable Style/WordArray
        aoa = [
          ['First', 'Second', 'Third'],
          ['|---------+----------+---------|', nil, nil],
          ['1', '2', '3.2'],
          ['4', '5', '6.4'],
          ['7', '8', '9.0'],
          [10, 11, 12.1]
        ]
        tab = Table.new(aoa)
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to eq(4)
        expect(tab.rows[0].keys.sort).to eq [:first, :second, :third]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:first].is_a?(Numeric)).to be true
          expect(row[:second].is_a?(Numeric)).to be true
          expect(row[:third].is_a?(BigDecimal)).to be true
        end
      end

      it 'should be create-able from an Array of Arrays with header no hrule' do
        aoa = [
          ['First', 'Second', 'Third'],
          ['1', '2', '3.2'],
          ['4', '5', '6.4'],
          ['7', '8', '9.0'],
          [10, 11, 12.1]
        ]
        tab = Table.new(aoa)
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to eq(4)
        expect(tab.headers.sort).to eq [:first, :second, :third]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:first].is_a?(Numeric)).to be true
          expect(row[:second].is_a?(Numeric)).to be true
          expect(row[:third].is_a?(BigDecimal)).to be true
        end
      end

      it 'should be create-able from an Array of Arrays sans Header' do
        aoa = [
          ['1', '2', '3.2'],
          ['4', '5', '6.4'],
          ['7', '8', '9.0'],
          [7, 8, 9.3]
        ]
        # rubocop:enable Style/WordArray
        tab = Table.new(aoa)
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to eq(4)
        expect(tab.headers.sort).to eq [:col1, :col2, :col3]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:col1].is_a?(Numeric)).to be true
          expect(row[:col2].is_a?(Numeric)).to be true
          expect(row[:col3].is_a?(BigDecimal)).to be true
        end
      end

      it 'should be create-able from an Array of Hashes' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3.2' },
          { a: '4', 'Two words' => '5', c: '6.4' },
          { a: '7', 'Two words' => '8', c: '9.0' },
          { a: 10, 'Two words' => 11, c: 12.4 }
        ]
        tab = Table.new(aoh)
        expect(tab.class).to eq(Table)
        expect(tab.rows.size).to eq(4)
        expect(tab.rows[0].keys.sort).to eq [:a, :c, :two_words]
        tab.rows.each do |row|
          row.each_pair do |k, _v|
            expect(k.class).to eq Symbol
          end
          expect(row[:a].is_a?(Numeric)).to be true
          expect(row[:two_words].is_a?(Numeric)).to be true
          expect(row[:c].is_a?(BigDecimal)).to be true
        end
      end

      it 'should set T F columns to Boolean' do
        cwd = File.dirname(__FILE__)
        dwtab = Table.new(cwd + '/../example_files/datawatch.org')
        expect(dwtab.column(:g10).type).to eq('Boolean')
      end
    end

    describe 'column operations' do
      it 'should be able to sum a column' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        expect(tab[:a].sum).to eq 12
        expect(tab[:two_words].sum).to eq 15
        expect(tab[:c].sum).to eq 19_423
        expect(tab[:d].sum).to eq 'appleorangepear'
      end

      it 'should be able to sum a column ignoring nils' do
        aoh = [
          { a: '', 'Two words' => '2', c: '', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        expect(tab[:a].sum).to eq 11
        expect(tab[:two_words].sum).to eq 15
        expect(tab[:c].sum).to eq 16_300
        expect(tab[:d].sum).to eq 'appleorangepear'
      end

      it 'should be able to report its headings' do
        tab = Table.new(StringIO.new(@csv_file_body), '.csv')
        expect(tab.headers.sort)
          .to eq [:code, :date, :info, :price, :rawshares, :ref, :shares]
      end

      it 'should be able to extract a column as an array' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        expect(tab[:a].to_a).to eq [1, 4, 7]
        expect(tab[:c].to_a).to eq [3123, 6412, 9888]
      end

      it 'should be able to sum a column' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        expect(tab[:a].sum).to eq 12
        expect(tab[:c].sum).to eq 19_423
        expect(tab[:c].sum.is_a?(Integer)).to be true
      end

      it 'should be able to average a column' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        expect(tab[:a].avg).to eq 4
        expect(tab[:c].avg.round(4)).to eq 6474.3333
        expect(tab[:c].avg.class).to eq BigDecimal
      end

      it 'should be able to get column minimum' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        expect(tab[:a].min).to eq 1
        expect(tab[:c].min.round(4)).to eq 3123
        expect(tab[:c].min.is_a?(Integer)).to be true
        expect(tab[:d].min).to eq 'apple'
      end

      it 'should be able to get column maximum' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        expect(tab[:a].max).to eq 7
        expect(tab[:c].max.round(4)).to eq 9888
        expect(tab[:c].max.is_a?(Integer)).to be true
        expect(tab[:d].max).to eq 'pear'
      end
    end

    describe 'footers' do
      it 'should be able to add a total footer to the table' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        tab.add_sum_footer([:a, :c, :two_words])
        expect(tab.footers[:total][:a]).to eq 12
        expect(tab.footers[:total][:c]).to eq 19_423
        expect(tab.footers[:total][:two_words]).to eq 15
        expect(tab.footers[:total][:d]).to be_nil
      end

      it 'should be able to add an average footer to the table' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        tab.add_avg_footer([:a, :c, :two_words])
        expect(tab.footers[:average][:a]).to eq 4
        expect(tab.footers[:average][:c].round(4)).to eq 6474.3333
        expect(tab.footers[:average][:two_words]).to eq 5
        expect(tab.footers[:average][:d]).to be_nil
      end

      it 'should be able to add a minimum footer to the table' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        tab.add_min_footer([:a, :c, :two_words])
        expect(tab.footers[:minimum][:a]).to eq 1
        expect(tab.footers[:minimum][:c]).to eq 3123
        expect(tab.footers[:minimum][:two_words]).to eq 2
        expect(tab.footers[:minimum][:d]).to be_nil
      end

      it 'should be able to add a maximum footer to the table' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        tab.add_max_footer([:a, :c, :two_words])
        expect(tab.footers[:maximum][:a]).to eq 7
        expect(tab.footers[:maximum][:c]).to eq 9888
        expect(tab.footers[:maximum][:two_words]).to eq 8
        expect(tab.footers[:maximum][:d]).to be_nil
      end
    end

    describe 'sorting' do
      it 'should be able to sort its rows on one column' do
        aoh = [
          { a: '5', 'Two words' => '20', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$1,888', d: 'apple' }
        ]
        tab = Table.new(aoh).order_by(:a)
        expect(tab.rows[0][:a]).to eq 4
      end

      it 'should be able to sort its rows on multiple columns' do
        aoh = [
          { a: '5', 'Two words' => '20', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$1,888', d: 'apple' }
        ]
        tab = Table.new(aoh).order_by(:d, :c)
        expect(tab.rows[0][:a]).to eq 7
      end

      it 'should be able to reverse sort its rows on one column' do
        aoh = [
          { a: '5', 'Two words' => '20', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$1,888', d: 'apple' }
        ]
        tab = Table.new(aoh).order_by(:d!)
        expect(tab.rows[0][:d]).to eq 'orange'
        expect(tab.rows[2][:d]).to eq 'apple'
      end

      it 'should sort its rows on mixed forward and reverse columns' do
        aoh = [
          { a: '5', 'Two words' => '20', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: 6412, d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$1,888', d: 'apple' }
        ]
        tab = Table.new(aoh).order_by(:d!, :c)
        expect(tab.rows[0][:d]).to eq 'orange'
        expect(tab.rows[1][:d]).to eq 'apple'
        expect(tab.rows[1][:c]).to eq 1888
        expect(tab.rows[2][:d]).to eq 'apple'
      end
    end

    describe 'union' do
      it 'should be able to union with a compatible table' do
        aoh = [
          { a: '5', 'Two words' => '20', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: 6412, d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$1,888', d: 'apple' }
        ]
        tab1 = Table.new(aoh)
        aoh2 = [
          { t: '8', 'Two worlds' => '65', s: '5,143', u: 'kiwi' },
          { t: '87', 'Two worlds' => '12', s: 412, u: 'banana' },
          { t: '13', 'Two worlds' => '11', s: '$1,821', u: 'grape' }
        ]
        tab2 = Table.new(aoh2)
        utab = tab1.union(tab2)
        expect(utab.rows.size).to eq(6)
      end

      it 'should throw an exception for union with different sized tables' do
        aoh = [
          { a: '5', 'Two words' => '20', c: '3,123' },
          { a: '4', 'Two words' => '5', c: 6412 },
          { a: '7', 'Two words' => '8', c: '$1,888' }
        ]
        tab1 = Table.new(aoh)
        aoh2 = [
          { t: '8', 'Two worlds' => '65', s: '5,143', u: 'kiwi' },
          { t: '87', 'Two worlds' => '12', s: 412, u: 'banana' },
          { t: '13', 'Two worlds' => '11', s: '$1,821', u: 'grape' }
        ]
        tab2 = Table.new(aoh2)
        expect {
          tab1.union(tab2)
        }.to raise_error(/different number of columns/)
      end

      it 'should throw an exception for union with different types' do
        aoh = [
          { a: '5', 'Two words' => '20', s: '5143',  c: '3123' },
          { a: '4', 'Two words' => '5',  s: 412,     c: 6412 },
          { a: '7', 'Two words' => '8',  s: '$1821', c: '$1888' }
        ]
        tab1 = Table.new(aoh)
        aoh2 = [
          { t: '8',  'Two worlds' => '65', s: '2016-01-17',   u: 'kiwi' },
          { t: '87', 'Two worlds' => '12', s: Date.today,     u: 'banana' },
          { t: '13', 'Two worlds' => '11', s: '[2015-05-21]', u: 'grape' }
        ]
        tab2 = Table.new(aoh2)
        expect {
          tab1.union(tab2)
        }.to raise_error(/different types/)
      end
    end

    describe 'select' do
      it 'should be able to select by column names' do
        aoh = [
          { a: '5', 'Two words' => '20', s: '5143',  c: '3123' },
          { a: '4', 'Two words' => '5',  s: 412,     c: 6412 },
          { a: '7', 'Two words' => '8',  s: '$1821', c: '$1888' }
        ]
        tab1 = Table.new(aoh)
        tab2 = tab1.select(:s, :a, :c)
        expect(tab2.headers).to eq [:s, :a, :c]
      end

      it 'should be able to select by column names renaming columns' do
        aoh = [
          { a: '5', 'Two words' => '20', s: '5143',  c: '3123' },
          { a: '4', 'Two words' => '5',  s: 412,     c: 6412 },
          { a: '7', 'Two words' => '8',  s: '$1821', c: '$1888' }
        ]
        tab1 = Table.new(aoh)
        tab2 = tab1.select(s: :former_s, a: :new_a, c: :renew_c)
        expect(tab2.headers).to eq [:former_s, :new_a, :renew_c]
      end

      it 'should be able to select new columns computed from prior' do
        aoh = [
          { a: '5', 'Two words' => '20', s: '5143',  c: '3123' },
          { a: '4', 'Two words' => '5',  s: 412,     c: 6412 },
          { a: '7', 'Two words' => '8',  s: '$1821', c: '$1888' }
        ]
        tab1 = Table.new(aoh)
        tab2 = tab1.select(:two_words, row: '@row', s_squared: 's * s',
                           arb: 's_squared / (a + c).to_d')
        expect(tab2.headers).to eq [:two_words, :row, :s_squared, :arb]
      end
    end

    describe 'where' do
      it 'should be able to filter rows by expression' do
        tab1 = Table.new(StringIO.new(@csv_file_body), '.csv')
        tab2 = tab1.where("date < Date.parse('2006-06-01')")
        expect(tab2[:date].max).to be < Date.parse('2006-06-01')
      end

      it 'should select by boolean columns' do
        tab =
          [['Ref', 'Date', 'Code', 'Raw', 'Shares', 'Price', 'Info', 'Bool'],
           [1, '2013-05-02', 'P', 795_546.20, 795_546.2, 1.1850, 'ZMPEF1', 'T'],
           [2, '2013-05-02', 'P', 118_186.40, 118_186.4, 11.8500, 'ZMPEF1', 'T'],
           [7, '2013-05-20', 'S', 12_000.00, 5046.00, 28.2804, 'ZMEAC', 'F'],
           [8, '2013-05-20', 'S', 85_000.00, 35_742.50, 28.3224, 'ZMEAC', 'T'],
           [9, '2013-05-20', 'S', 33_302.00, 14_003.49, 28.6383, 'ZMEAC', 'T'],
           [10, '2013-05-23', 'S', 8000.00, 3364.00, 27.1083, 'ZMEAC', 'T'],
           [11, '2013-05-23', 'S', 23_054.00, 9694.21, 26.8015, 'ZMEAC', 'F'],
           [12, '2013-05-23', 'S', 39_906.00, 16_780.47, 25.1749, 'ZMEAC', 'T'],
           [13, '2013-05-29', 'S', 13_459.00, 5659.51, 24.7464, 'ZMEAC', 'T'],
           [14, '2013-05-29', 'S', 15_700.00, 6601.85, 24.7790, 'ZMEAC', 'F'],
           [15, '2013-05-29', 'S', 15_900.00, 6685.95, 24.5802, 'ZMEAC', 'T'],
           [16, '2013-05-30', 'S', 6_679.00, 2808.52, 25.0471, 'ZMEAC', 'T']]
        tab = Table.new(tab).add_sum_footer([:raw, :shares, :price])
        tab2 = tab.where('!bool || code == "P"')
        expect(tab2.rows.size).to eq(5)
        tab2 = tab.where('code == "S" && raw < 10_000')
        expect(tab2.rows.size).to eq(2)
        tab2 = tab.where('@row > 10')
        expect(tab2.rows.size).to eq(2)
        tab2 = tab.where('info =~ /zmeac/i')
        expect(tab2.rows.size).to eq(10)
        tab2 = tab.where('info =~ /xxxx/')
        expect(tab2.rows.size).to eq(0)
      end

    end

    describe 'group_by' do
      it 'should be able to group by equal columns' do
        tab1 = Table.new(StringIO.new(@csv_file_body), '.csv')
        tab2 = tab1.group_by(:date, :code, shares: :sum, ref: :first)
        expect(tab2.headers).to eq([:date, :code, :sum_shares, :first_ref,
                                    :first_rawshares, :first_price, :first_info])
      end
    end

    describe 'output' do
      it 'should be able to return itself as an array of arrays' do
        aoh = [
          { a: '1', 'Two words' => '2', c: '3,123', d: 'apple' },
          { a: '4', 'Two words' => '5', c: '6,412', d: 'orange' },
          { a: '7', 'Two words' => '8', c: '$9,888', d: 'pear' }
        ]
        tab = Table.new(aoh)
        aoa = tab.to_org
        expect(aoa.class).to eq Array
        expect(aoa[0].class).to eq Array
        expect(aoa[0][0]).to eq 'A'
      end

      it 'should be able to output an org babel aoa' do
        # This is what the data looks like when called from org babel code
        # blocks.
        tab =
          [['Ref', 'Date', 'Code', 'Raw', 'Shares', 'Price', 'Info', 'Bool'],
           [1, '2013-05-02', 'P', 795_546.20, 795_546.2, 1.1850, 'ZMPEF1', 'T'],
           [2, '2013-05-02', 'P', 118_186.40, 118_186.4, 11.8500, 'ZMPEF1', 'T'],
           [7, '2013-05-20', 'S', 12_000.00, 5046.00, 28.2804, 'ZMEAC', 'F'],
           [8, '2013-05-20', 'S', 85_000.00, 35_742.50, 28.3224, 'ZMEAC', 'T'],
           [9, '2013-05-20', 'S', 33_302.00, 14_003.49, 28.6383, 'ZMEAC', 'T'],
           [10, '2013-05-23', 'S', 8000.00, 3364.00, 27.1083, 'ZMEAC', 'T'],
           [11, '2013-05-23', 'S', 23_054.00, 9694.21, 26.8015, 'ZMEAC', 'F'],
           [12, '2013-05-23', 'S', 39_906.00, 16_780.47, 25.1749, 'ZMEAC', 'T'],
           [13, '2013-05-29', 'S', 13_459.00, 5659.51, 24.7464, 'ZMEAC', 'T'],
           [14, '2013-05-29', 'S', 15_700.00, 6601.85, 24.7790, 'ZMEAC', 'F'],
           [15, '2013-05-29', 'S', 15_900.00, 6685.95, 24.5802, 'ZMEAC', 'T'],
           [16, '2013-05-30', 'S', 6_679.00, 2808.52, 25.0471, 'ZMEAC', 'T']]
        tg = Table.new(tab).add_sum_footer([:raw, :shares, :price])
        aoa = tg.to_org(formats: { raw: '%,', shares: '%,', price: '%,4' })
        expect(aoa[-1][0]).to eq 'Total'
        expect(aoa[-1][1]).to eq ''
        expect(aoa[-1][2]).to eq ''
        expect(aoa[-1][3]).to eq '1,166,733'
        expect(aoa[-1][4]).to eq '1,020,119'
        expect(aoa[-1][5]).to eq '276.5135'
      end
    end
  end
end
