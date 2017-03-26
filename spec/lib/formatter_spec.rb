require 'spec_helper'

module FatCore
  describe Formatter do
    before :all do
      aoa =
        [['Ref', 'Date', 'Code', 'Raw', 'Shares', 'Price', 'Info', 'Bool'],
         nil,
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
      @tab = Table.from_aoa(aoa)
    end

    it 'should raise error for invalid location' do
      fmt = Formatter.new(@tab)
      expect {
        fmt.format_for(:trout, string: 'BC')
      }.to raise_error(/unknown format location/)
    end

    it 'should raise error for invalid format string' do
      fmt = Formatter.new(@tab)
      expect {
        fmt.format_for(:body, string: 'OOIUOIO')
      }.to raise_error(/unrecognized string formatting instruction/)
    end

    it 'should raise error for inapposite format string' do
      fmt = Formatter.new(@tab)
      expect {
        fmt.format_for(:body, boolean: '7.4,')
      }.to raise_error(/unrecognized boolean formatting instruction/)
    end

    it 'should be able to set element formats' do
      fmt = Formatter.new(@tab)
              .format_for(:header, string: 'Uc[red]', ref: 'c[blue]')
              .format_for(:gfooter, string: 'B')
              .format_for(:footer, date: 'Bd[%Y]')
              .format_for(:body, numeric: ',0.2', shares: '0.4', ref: 'B',
                          bool: '  c[green, red]  b[  Yippers, Nah Sir]',
                          nil: 'n[  Nothing to see here   ]')
      # Header color
      expect(fmt.format[:header][:ref].color).to eq('blue')
      expect(fmt.format[:header][:date].color).to eq('red')
      expect(fmt.format[:header][:code].color).to eq('red')
      expect(fmt.format[:header][:raw].color).to eq('red')
      expect(fmt.format[:header][:shares].color).to eq('red')
      expect(fmt.format[:header][:price].color).to eq('red')
      expect(fmt.format[:header][:info].color).to eq('red')
      expect(fmt.format[:header][:bool].color).to eq('red')
      # Header case
      expect(fmt.format[:header][:ref].case).to eq(:none)
      expect(fmt.format[:header][:date].case).to eq(:upper)
      expect(fmt.format[:header][:code].case).to eq(:upper)
      expect(fmt.format[:header][:raw].case).to eq(:upper)
      expect(fmt.format[:header][:shares].case).to eq(:upper)
      expect(fmt.format[:header][:price].case).to eq(:upper)
      expect(fmt.format[:header][:info].case).to eq(:upper)
      expect(fmt.format[:header][:bool].case).to eq(:upper)
      # Header all others, the default
      @tab.headers.each do |h|
        expect(fmt.format[:header][h].true_color).to eq('black')
        expect(fmt.format[:header][h].false_color).to eq('black')
        expect(fmt.format[:header][h].true_text).to eq('T')
        expect(fmt.format[:header][h].false_text).to eq('F')
        expect(fmt.format[:header][h].strftime_fmt).to eq('%F')
        expect(fmt.format[:header][h].nil_text).to eq('')
        expect(fmt.format[:header][h].pre_digits).to eq(-1)
        expect(fmt.format[:header][h].post_digits).to eq(-1)
        expect(fmt.format[:header][h].bold).to eq(false)
        expect(fmt.format[:header][h].italic).to eq(false)
        expect(fmt.format[:header][h].alignment).to eq(:left)
        expect(fmt.format[:header][h].commas).to eq(false)
        expect(fmt.format[:header][h].currency).to eq(false)
        expect(fmt.format[:header][h].nil_text).to eq('')
      end
      # Gfooter bold
      @tab.headers.each do |h|
        expect(fmt.format[:gfooter][h].bold).to eq(true)
      end
      # Gfooter all others, the default
      @tab.headers.each do |h|
        expect(fmt.format[:gfooter][h].true_color).to eq('black')
        expect(fmt.format[:gfooter][h].false_color).to eq('black')
        expect(fmt.format[:gfooter][h].color).to eq('black')
        expect(fmt.format[:gfooter][h].true_text).to eq('T')
        expect(fmt.format[:gfooter][h].false_text).to eq('F')
        expect(fmt.format[:gfooter][h].strftime_fmt).to eq('%F')
        expect(fmt.format[:gfooter][h].nil_text).to eq('')
        expect(fmt.format[:gfooter][h].pre_digits).to eq(-1)
        expect(fmt.format[:gfooter][h].post_digits).to eq(-1)
        expect(fmt.format[:gfooter][h].italic).to eq(false)
        expect(fmt.format[:gfooter][h].alignment).to eq(:left)
        expect(fmt.format[:gfooter][h].commas).to eq(false)
        expect(fmt.format[:gfooter][h].currency).to eq(false)
        expect(fmt.format[:gfooter][h].nil_text).to eq('')
      end
      # Footer date strftime_fmt for :date
      expect(fmt.format[:footer][:date].strftime_fmt).to eq('%Y')
      expect(fmt.format[:footer][:date].bold).to eq(true)
      # Footer all others, the default
      @tab.headers.each do |h|
        expect(fmt.format[:footer][h].true_color).to eq('black')
        expect(fmt.format[:footer][h].false_color).to eq('black')
        expect(fmt.format[:footer][h].color).to eq('black')
        expect(fmt.format[:footer][h].true_text).to eq('T')
        expect(fmt.format[:footer][h].false_text).to eq('F')
        expect(fmt.format[:footer][h].strftime_fmt).to eq(h == :date ? '%Y' : '%F')
        expect(fmt.format[:footer][h].nil_text).to eq('')
        expect(fmt.format[:footer][h].pre_digits).to eq(-1)
        expect(fmt.format[:footer][h].post_digits).to eq(-1)
        expect(fmt.format[:footer][h].bold).to eq(h == :date)
        expect(fmt.format[:footer][h].italic).to eq(false)
        expect(fmt.format[:footer][h].alignment).to eq(:left)
        expect(fmt.format[:footer][h].commas).to eq(false)
        expect(fmt.format[:footer][h].currency).to eq(false)
        expect(fmt.format[:footer][h].nil_text).to eq('')
      end
      # .format_for(:body, numeric: ',0.2', shares: '0.4', ref: 'B',
      #             bool: '  c[green, red]  b[  Yippers, Nah Sir]',
      #             nil: 'n[  Nothing to see here   ]')
      # Body, numeric columns except :shares
      [:raw, :price].each do |h|
        expect(fmt.format[:body][h].commas).to eq(true)
        expect(fmt.format[:body][h].pre_digits).to eq(0)
        expect(fmt.format[:body][h].post_digits).to eq(2)
      end
      # Body, :shares
      expect(fmt.format[:body][:shares].commas).to eq(false)
      expect(fmt.format[:body][:shares].pre_digits).to eq(0)
      expect(fmt.format[:body][:shares].post_digits).to eq(4)
      # Body, :bool
      expect(fmt.format[:body][:bool].true_color).to eq('green')
      expect(fmt.format[:body][:bool].false_color).to eq('red')
      expect(fmt.format[:body][:bool].true_text).to eq('Yippers')
      expect(fmt.format[:body][:bool].false_text).to eq('Nah Sir')
      # Body, :ref
      expect(fmt.format[:body][:ref].bold).to eq(true)
      # Body all others, the default
      @tab.headers.each do |h|
        expect(fmt.format[:body][h].color).to eq('black')
        unless h == :bool
          expect(fmt.format[:body][h].true_color).to eq('black')
          expect(fmt.format[:body][h].false_color).to eq('black')
          expect(fmt.format[:body][h].true_text).to eq('T')
          expect(fmt.format[:body][h].false_text).to eq('F')
        end
        expect(fmt.format[:body][h].strftime_fmt).to eq('%F')
        unless [:raw, :price, :shares].include?(h)
          expect(fmt.format[:body][h].pre_digits).to eq(-1)
          expect(fmt.format[:body][h].post_digits).to eq(-1)
          expect(fmt.format[:body][h].commas).to eq(false)
        end
        unless h == :ref
          expect(fmt.format[:body][h].bold).to eq(false)
        end
        expect(fmt.format[:body][h].italic).to eq(false)
        expect(fmt.format[:body][h].alignment).to eq(:left)
        expect(fmt.format[:body][h].currency).to eq(false)
        expect(fmt.format[:body][h].nil_text).to eq('Nothing to see here')
      end
    end
  end
end
