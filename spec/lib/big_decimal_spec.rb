require 'fat_core/big_decimal'

describe BigDecimal do
  it 'should provide a human-readable inspect for BigDecimal' do
    expect(BigDecimal.new('33.45').inspect).to eq '33.45'
  end
end
