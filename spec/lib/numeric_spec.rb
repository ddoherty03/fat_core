# frozen_string_literal: true

require 'spec_helper'
require 'fat_core/numeric'

describe Numeric do
  it 'implements signum function' do
    # Integers
    expect(33.signum).to eq 1
    expect(-33.signum).to eq(-1)
    expect(0.signum).to eq 0

    # Floats
    expect(33.45.signum).to eq 1
    expect(-33.45.signum).to eq(-1)
    expect(0.0.signum).to eq 0
  end

  it 'provides a tex_quote method for erb docs' do
    expect(195.45.tex_quote).to eq '195.45'
    expect(195.00.tex_quote).to eq '195.0'
    expect(58743.44.tex_quote).to eq '58743.44'
    expect(Float::INFINITY.tex_quote).to eq("$\\infty$")
    expect((-Float::INFINITY).tex_quote).to eq("$-\\infty$")
    expect(Complex(5, 3).tex_quote).to eq("$5+3i$")
    expect(Complex(7, 1).tex_quote).to eq("$7+i$")
    expect(Complex(7.00, 1).tex_quote).to eq("$7+i$")
    expect(Complex(Math::PI, 1).tex_quote).to eq("$\\pi+i$")
    expect(Complex(Math::E, 1).tex_quote).to eq("$e+i$")
    expect(Complex(Math::E, Math::PI).tex_quote).to eq("$e+\\pi i$")
    expect(Complex(Math::PI, Math::E).tex_quote).to eq("$\\pi+e i$")
    expect(Rational(5, 3).tex_quote).to eq("$\\frac{5}{3}$")
  end

  it 'knows if its a whole number' do
    expect(236.whole?).to be true
    expect(236.5555.whole?).to be false
  end

  it 'properly rounds up' do
    expect(236.5555.commas(2)).to eq '236.56'
    expect(-236.5555.commas(2)).to eq '-236.56'
  end

  it 'properly rounds down' do
    expect(236.5512.commas(2)).to eq '236.55'
    expect(-236.5512.commas(2)).to eq '-236.55'
  end

  it 'places commas properly' do
    expect(123_456_789.0123.commas(2)).to eq '123,456,789.01'
    expect(-123_456_789.0123.commas(2)).to eq '-123,456,789.01'

    # if places is nil, use 4 places for numbers with a fractional
    # part and 0 places for numbers without
    expect(-123_456_789.0123456.commas).to eq '-123,456,789.0123456'
    expect(-123_456_789.0.commas).to eq '-123,456,789'
    expect(-123_456_789.00.commas).to eq '-123,456,789'
  end

  it 'converts a non-fractional float to an int' do
    expect(195.45.int_if_whole).to eq 195.45
    expect(195.0.int_if_whole).to eq 195
    expect(195.0.int_if_whole.is_a?(Integer)).to be true
  end

  it 'places commas properly with no fraction' do
    expect(123_456_789.commas).to eq '123,456,789'
    expect(-123_456_789.commas).to eq '-123,456,789'
  end

  it 'does not place commas in a number with exponent' do
    expect(123_456.789e100.commas).to eq '1.23456789e+105'
  end

  it 'converts itself into an H:M:S string' do
    expect(60.secs_to_hms).to eq('00:01:00')
    expect(120.secs_to_hms).to eq('00:02:00')
    expect(6584.secs_to_hms).to eq('01:49:44')
    expect(6584.35.secs_to_hms).to eq('01:49:44.35')
  end
end
