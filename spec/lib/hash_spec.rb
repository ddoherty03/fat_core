# frozen_string_literal: true

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
    expect(hh.delete_with_value!(1)).to eq({ :b => 2 })
    expect(hh.delete_with_value!(9)).to eq hh
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

  it 'can take any Enumerable as a right argument' do
    FileUtils.mkdir_p('./tmp')
    ff = File.open('./tmp/junk', 'w')
    ff.write("f\n", "FFFF\n", "g\n", "GGGG\n")
    ff.close
    ff = File.open('./tmp/junk', 'r')
    h = { a: 'A', b: 'B', c: 'C' } << [:c, 'CC', :d, 'DD'] <<
        { d: 'DDD', e: 'EEE' } <<
        ff.readlines.map(&:chomp)
    h.transform_keys!(&:to_sym)
    ff.close
    expect(h.keys).to include(:a, :b, :c, :d, :e, :f, :g)
    FileUtils.rm_rf('./tmp/junk')
  end
end
