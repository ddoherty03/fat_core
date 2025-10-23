# frozen_string_literal: true

require 'spec_helper'
require 'fat_core/enumerable'

describe Enumerable do
  it 'enumerates groups of size k' do
    letters = ('a'..'z').to_a
    letters.groups_of(3).each do |_k, grp|
      expect(grp.class).to eq Array
      if grp.last == 'z'
        expect(grp.size).to eq(2)
        expect(grp).to eq(['y', 'z'])
      else
        expect(grp.size).to eq(3)
        expect(grp.join).to match(/\A[a-z]{3}\z/)
      end
    end
  end

  it 'enumerates each with first and last flags' do
    letters = ('a'..'z').to_a
    letters.each_with_flags do |l, first, last|
      if l == 'a'
        expect(first).to be true
        expect(last).to be false
      elsif l == 'z'
        expect(first).to be false
        expect(last).to be true
      else
        expect(first).to be false
        expect(last).to be false
      end
    end
  end

  it 'returns nil enumerating a beginless Range' do
    bless = (..100)
    result = bless.each_with_flags { |_l, _first, _last| 44 }
    expect(result).to be_nil
  end

  it 'enumerates an endless Range' do
    eless = (1..)
    num = 0
    eless.each_with_flags do |i, _first, _last|
      num += i
      break if i >= 100
    end
    # Look at me, I'm Gauss
    expect(num).to eq(5050)
  end
end
