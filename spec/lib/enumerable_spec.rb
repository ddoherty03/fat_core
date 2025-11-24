# frozen_string_literal: true

require 'spec_helper'
require 'fat_core/enumerable'

describe Enumerable do
  describe '#each_with_flags' do
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
end
