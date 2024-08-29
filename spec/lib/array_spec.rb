require 'spec_helper'

require 'fat_core/array'

describe Array do
  it 'reports its last index' do
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

  it 'comma_join' do
    expect(%w[].comma_join).to eq('')
    expect(%w[A].comma_join).to eq('A')
    expect(%w[A B].comma_join).to eq('A and B')
    expect(%w[A B C].comma_join).to eq('A, B, and C')
    expect([1, 1, 2, 3, 5, 8].comma_join).to eq('1, 1, 2, 3, 5, and 8')
  end

  it 'comma_join with only sep param' do
    expect(%w[].comma_join(sep: '-')).to eq('')
    expect(%w[A].comma_join(sep: '-')).to eq('A')
    expect(%w[A B].comma_join(sep: '-')).to eq('A-B')
    expect(%w[A B C].comma_join(sep: '-')).to eq('A-B-C')
    expect([1, 1, 2, 3, 5, 8].comma_join(sep: '-')).to eq('1-1-2-3-5-8')
  end

  it 'comma_join with only last_sep param' do
    expect(%w[].comma_join(last_sep: '*')).to eq('')
    expect(%w[A].comma_join(last_sep: '*')).to eq('A')
    expect(%w[A B].comma_join(last_sep: '*')).to eq('A*B')
    expect(%w[A B C].comma_join(last_sep: '*')).to eq('A, B*C')
    expect([1, 1, 2, 3, 5, 8].comma_join(last_sep: '*')).to eq('1, 1, 2, 3, 5*8')
  end
end
