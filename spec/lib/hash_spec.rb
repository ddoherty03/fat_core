require 'spec_helper'
require 'fat_core/hash'

describe Hash do
  it 'finds keys with a value == to X' do
    hh = { :a => 1, :b => 2, :c => 1 }
    expect(hh.keys_with_value(1)).to eq [:a, :c]
    expect(hh.keys_with_value(9)).to eq []
  end

  it 'deletes entries with a value == to X' do
    hh = { :a => 1, :b => 2, :c => 1 }
    expect(hh.delete_with_value(1)).to eq({ :b => 2 })
    expect(hh.delete_with_value(9)).to eq hh
  end

  it 'maps keys to new keys' do
    hh = { :a => 1, :b => 2, :c => 1 }
    remap = { :a => :d, :b => :e, :c => :f }
    expect(hh.remap_keys(remap)).to eq({ :d => 1, :e => 2, :f => 1 })

    remap = { :a => :d }
    expect(hh.remap_keys(remap)).to eq({ :d => 1, :b => 2, :c => 1 })
  end

  it 'make << an alias for Hash#merge' do
    h1 = { a: 'A', b: 'B', c: 'C' }
    h2 = { b: 'BB', d: 'DD' }
    h3 = { e: 'EEE' }
    expect(h1 << h2 << h3).to eq({ a: 'A', b: 'BB', c: 'C', d: 'DD', e: 'EEE' })
  end
end
