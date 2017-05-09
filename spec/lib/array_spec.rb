require 'spec_helper'

require 'fat_core/array'

describe Array do
  it 'should be able to report its last index' do
    letters = ('a'..'z').to_a
    expect(letters.last_i).to eq(25)
  end

  it 'intersection' do
    expect(%w(A A B A C A B).intersect(%w(A B A))).to eq(%w(A A B A A B))
    expect(%w(A A B A C A B).intersect(%w(A B))).to eq(%w(A A B A A B))
    expect(%w(A A B A C A B).intersect(%w(A))).to eq(%w(A A A A))
    expect(%w(A A B A C A B).intersect(%w(B))).to eq(%w(B B))
    expect(%w(A A B A C A B).intersect(%w(C))).to eq(%w(C))
  end

  it 'difference' do
    expect(%w(A A B A C A B).difference(%w(A B A))).to eq(%w(C))
    expect(%w(A A B A C A B).difference(%w(A B))).to eq(%w(C))
    expect(%w(A A B A C A B).difference(%w(A))).to eq(%w(B C B))
    expect(%w(A A B A C A B).difference(%w(B))).to eq(%w(A A A C A))
    expect(%w(A A B A C A B).difference(%w(C))).to eq(%w(A A B A A B))
  end
end
