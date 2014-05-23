require 'spec_helper'

describe Kernel do
  it "should know how to time a block of code" do
    result = time_it "do something" do
      (1..10_000_000).each { |k| k * k }
      "hello"
    end
    expect(result).to eq('hello')
  end
end
