require 'spec_helper'

describe Array do
  it 'should be able to report its last index' do
    letters = ('a'..'z').to_a
    expect(letters.last_i).to eq(25)
  end
end
