require 'spec_helper'

describe Enumerable do
  it 'should be able to emit in groups of size k' do
    letters = ('a'..'z').to_a
    letters.groups_of(3).each do |k, grp|
      expect(grp.join).to match(/\A[a-z]{1,3}\z/)
    end
  end
end
