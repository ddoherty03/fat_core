require 'spec_helper'

module FatCore
  describe Column do
    describe 'construction' do
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

      it 'should recognize Date columns but allow DateTime and nil' do
        c = Column.new(header: :when,
                       items: [nil, '2015-01-21', '[2015-01-12]',
                               '<2011-01-06>', nil, '<2017-01-25 Wed 10:00>'])
        expect(c.type).to eq('Date')
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
    end
  end
end
