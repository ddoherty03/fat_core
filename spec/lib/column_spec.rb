require 'spec_helper'

module FatCore
  describe Column do
    describe 'construction' do
      it 'should be able to append items to the column' do
        c = Column.new(header: 'junk')
        expect(c.type).to eq('NilClass')
        c << '2.71828'
        expect(c.items).to eq([2.71828])
        expect(c.type).to eq('Numeric')
      end

      it 'should leave the type of an all-nil column open' do
        c = Column.new(header: :bool, items: [nil, nil, nil, nil])
        expect(c.type).to eq('NilClass')
        expect(c[0]).to eq(nil)
        expect(c[1]).to eq(nil)
        expect(c[2]).to eq(nil)
        expect(c[3]).to eq(nil)
        # But then, assign a type when a recognizable type comes along.
        c << '625.18'
        expect(c.type).to eq('Numeric')
        expect { c << '2018-05-06' }.to raise_error /already typed as Numeric/
      end

      it 'should recognize boolean columns' do
        c = Column.new(header: :bool, items: [nil, 'F', 'F', 'T'])
        expect(c.type).to eq('Boolean')
        c = Column.new(header: :bool,
                       items: [nil, 'N', 'no', 'yes', 'false', 'TRUE', nil])
        expect(c.type).to eq('Boolean')
        expect(c[0]).to eq(nil)
        expect(c[1]).to eq(false)
        expect(c[2]).to eq(false)
        expect(c[3]).to eq(true)
        expect(c[4]).to eq(false)
        expect(c[5]).to eq(true)
        expect(c[6]).to eq(nil)
      end

      it 'should recognize DateTime columns but allow Date and nil' do
        c = Column.new(header: :when,
                       items: [nil, '2015-01-21', '[2015-01-12]',
                               '<2011-01-06>', nil, '<2017-01-25 Wed 10:00>'])
        expect(c.type).to eq('DateTime')
        expect(c[0]).to eq(nil)
        expect(c[1]).to eq(Date.parse('2015-01-21'))
        expect(c[2]).to eq(Date.parse('2015-01-12'))
        expect(c[3]).to eq(Date.parse('2011-01-06'))
        expect(c[4]).to eq(nil)
        expect(c[5]).to eq(DateTime.parse('2017-01-25 Wed 10:00'))
        expect(c[1].class).to eq(Date)
        expect(c[5].class).to eq(DateTime)
      end

      it 'should recognize Numeric columns but allow nils and Integers' do
        c = Column.new(header: :when,
                       items: [nil, '20151', '3.14159',
                               BigDecimal('2.718281828'), nil,
                               '45024098204982340982049802348'])
        expect(c.type).to eq('Numeric')
        expect(c[0]).to eq(nil)
        expect(c[1]).to eq(20151)
        expect(c[2]).to eq(3.14159)
        expect(c[3]).to eq(2.718281828)
        expect(c[4]).to eq(nil)
        expect(c[5]).to eq(45024098204982340982049802348)
        expect(c[0].class).to eq(NilClass)
        expect(c[1].class).to eq(Fixnum)
        expect(c[2].class).to eq(BigDecimal)
        expect(c[3].class).to eq(BigDecimal)
        expect(c[4].class).to eq(NilClass)
        expect(c[5].class).to eq(Bignum)
      end

      it 'should recognize String columns but allow nils and Integers' do
        c = Column.new(header: :when,
                       items: [nil, 'Four', 'score', 'and', nil, '7 years'])
        expect(c.type).to eq('String')
        expect(c[0]).to eq(nil)
        expect(c[1]).to eq('Four')
        expect(c[2]).to eq('score')
        expect(c[3]).to eq('and')
        expect(c[4]).to eq(nil)
        expect(c[5]).to eq('7 years')
        expect(c[0].class).to eq(NilClass)
        expect(c[1].class).to eq(String)
        expect(c[2].class).to eq(String)
        expect(c[3].class).to eq(String)
        expect(c[4].class).to eq(NilClass)
        expect(c[5].class).to eq(String)
      end
    end

    describe 'attribute getting and setting' do
      it 'should be able to retrieve items by index number' do
        c = Column.new(header: :when,
                       items: [nil, '20151', '3.14159',
                               BigDecimal('2.718281828'), nil,
                               '45024098204982340982049802348'])
        expect(c[0]).to eq(nil)
        expect(c[1]).to eq(20151)
        expect(c[2]).to eq(3.14159)
        expect(c[3]).to eq(2.718281828)
        expect(c[4]).to eq(nil)
        expect(c[5]).to eq(45024098204982340982049802348)
      end

      it 'should respond to to_a, size, empty?, and last_i' do
        arr = [nil, '20151', '3.14159',
               BigDecimal('2.718281828'), nil,
               '45024098204982340982049802348']
        c = Column.new(header: :when, items: arr)
        expect(c.to_a).to eq([nil, 20151, 3.14159, 2.718281828,
                              nil, 45024098204982340982049802348])
        expect(c.to_a.class).to eq(Array)
        expect(c.size).to eq(6)
        expect(c.empty?).to eq(false)
        expect(c.last_i).to eq(5)
      end
    end

    describe 'aggregates' do
      before :each do
        @nil_col =
          Column.new(header: :none, items: [nil, nil, nil, nil])
        @bool_col =
          Column.new(header: :bool,
                     items: [nil, 'N', 'no', 'yes', 'false', 'TRUE', nil])
        @date_col =
          Column.new(header: :when,
                     items: [nil, '2015-01-21', '[2015-01-12]',
                             '<2011-01-06>', nil, '<2017-01-25 Wed 10:00>'])
        @num_col =
          Column.new(header: :nums,
                     items: [nil, '20151', '3.14159',
                             BigDecimal('2.718281828'), nil, '45024'])
        @str_col =
          Column.new(header: :strs,
                     items: [nil, 'Four', 'score', 'and', nil, '7 years'])
      end

      it 'should be able apply to first to appropriate columns' do
        expect(@nil_col.first).to eq(nil)
        expect(@bool_col.first).to eq(false)
        expect(@date_col.first).to eq(Date.parse('2015-01-21'))
        expect(@num_col.first).to eq(20151)
        expect(@str_col.first).to eq('Four')
      end

      it 'should be able to apply last to appropriate columns' do
        expect(@nil_col.last).to eq(nil)
        expect(@bool_col.last).to eq(true)
        expect(@date_col.last).to eq(DateTime.parse('2017-01-25 10am'))
        expect(@num_col.last).to eq(45024)
        expect(@str_col.last).to eq('7 years')
      end

      it 'should be able to apply rng_s to appropriate columns' do
        expect(@nil_col.rng_s).to eq('..')
        expect(@bool_col.rng_s).to eq('false..true')
        expect(@date_col.rng_s).to eq('2015-01-21..2017-01-25T10:00:00+00:00')
        expect(@num_col.rng_s).to eq('20151..45024')
        expect(@str_col.rng_s).to eq('Four..7 years')
      end

      it 'should be able to sum to appropriate columns' do
        expect { @nil_col.sum }.to raise_error(/cannot be applied/)
        expect { @bool_col.sum }.to raise_error(/cannot be applied/)
        expect { @date_col.sum }.to raise_error(/cannot be applied/)
        expect(@num_col.sum).to eq(65180.859871828)
        expect(@str_col.sum).to eq('Fourscoreand7 years')
      end

      it 'should be able to min to appropriate columns' do
        expect(@nil_col.min).to eq(nil)
        expect { @bool_col.min }.to raise_error(/cannot be applied/)
        expect(@date_col.min).to eq(Date.parse('2011-01-06'))
        expect(@num_col.min).to eq(BigDecimal('2.718281828'))
        expect(@str_col.min).to eq('7 years')
      end

      it 'should be able to max to appropriate columns' do
        expect(@nil_col.max).to eq(nil)
        expect { @bool_col.max }.to raise_error(/cannot be applied/)
        expect(@date_col.max).to eq(DateTime.parse('2017-01-25 10am'))
        expect(@num_col.max).to eq(45024)
        expect(@str_col.max).to eq('score')
      end

      it 'should be able to apply avg to appropriate columns' do
        expect { @nil_col.avg }.to raise_error(/cannot be applied/)
        expect { @bool_col.avg }.to raise_error(/cannot be applied/)
        expect(@date_col.avg).to eq(DateTime.parse('2014-07-17 12pm'))
        expect(@num_col.avg).to eq(16295.214967957)
        expect{ @str_col.avg }.to raise_error(/cannot be applied/)
      end

      it 'should be able to apply boolean aggregates to boolean columns' do
        expect(@bool_col.any?).to eq(true)
        expect(@bool_col.all?).to eq(false)
        expect(@bool_col.none?).to eq(false)
        expect(@bool_col.one?).to eq(false)
      end
    end
  end
end
