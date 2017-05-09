require 'spec_helper'

require 'fat_core/enumerable'

describe Enumerable do
  it 'should be able to emit in groups of size k' do
    letters = ('a'..'z').to_a
    letters.groups_of(3).each do |k, grp|
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

  it 'should be able to yield each with flags' do
    letters = ('a'..'z').to_a
    letters.each_with_flags do |l, first, last|
      if l == 'a'
        expect(first).to eq true
        expect(last).to eq false
      elsif l == 'z'
        expect(first).to eq false
        expect(last).to eq true
      else
        expect(first).to eq false
        expect(last).to eq false
      end
    end
  end
end
