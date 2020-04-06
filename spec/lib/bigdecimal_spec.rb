require 'spec_helper'
require 'fat_core/bigdecimal'

describe BigDecimal do
  it 'should provide a human-readable inspect for BigDecimal' do
    expect(BigDecimal('33.45').inspect).to eq '33.45'
  end
end
