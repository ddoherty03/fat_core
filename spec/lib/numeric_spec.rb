require File.dirname(File.absolute_path(__FILE__)) + '/../spec_helper.rb'

describe Numeric do
  it "should properly round up" do
    expect(236.5555.commas(2)).to eq '236.56'
    expect(-236.5555.commas(2)).to eq '-236.56'
  end

  it "should properly round down" do
    expect(236.5512.commas(2)).to eq '236.55'
    expect(-236.5512.commas(2)).to eq '-236.55'
  end

  it "should place commas properly" do
    expect(123456789.0123.commas(2)).to eq '123,456,789.01'
    expect(-123456789.0123.commas(2)).to eq '-123,456,789.01'
  end

  it "should place commas properly with no fraction" do
    expect(123456789.commas).to eq '123,456,789'
    expect(-123456789.commas).to eq '-123,456,789'
  end

  it "should not place commas in a number with exponent" do
    expect(123456.789e100.commas).to eq '1.23456789e+105'
  end

  it "should be able to convert itself into an H:M:S string" do
    expect(60.secs_to_hms).to eq('00:01:00')
    expect(120.secs_to_hms).to eq('00:02:00')
    expect(6584.secs_to_hms).to eq('01:49:44')
    expect(6584.35.secs_to_hms).to eq('01:49:44.35')
  end
end
