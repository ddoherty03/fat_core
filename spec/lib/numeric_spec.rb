require File.dirname(File.absolute_path(__FILE__)) + '/../spec_helper.rb'

describe Numeric do
  it "should properly round up" do
    236.5555.commas(2).should == '236.56'
    -236.5555.commas(2).should == '-236.56'
  end

  it "should properly round down" do
    236.5512.commas(2).should == '236.55'
    -236.5512.commas(2).should == '-236.55'
  end

  it "should place commas properly" do
    123456789.0123.commas(2).should == '123,456,789.01'
    -123456789.0123.commas(2).should == '-123,456,789.01'
  end

  it "should place commas properly with no fraction" do
    123456789.commas.should == '123,456,789'
    -123456789.commas.should == '-123,456,789'
  end

  it "should not place commas in a number with exponent" do
    123456.789e100.commas.should == '1.23456789e+105'
  end
end
