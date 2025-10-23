# frozen_string_literal: true

require 'spec_helper'
require 'fat_core/kernel'

describe Kernel do
  it 'knows how to time a block of code' do
    expect {
      time_it 'do something' do
        (1..10_000_000).each { |k| k * k }
        'hello'
      end
    }.to output(/Ran do something in/i).to_stdout
  end
end
