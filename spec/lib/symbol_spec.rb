# frozen_string_literal: true

require 'spec_helper'
require 'fat_core/symbol'

describe Symbol do
  it 'converts to a capitalized string' do
    expect(:i_am_a_symbol.entitle).to eq 'I Am a Symbol'
    2
  end

  it 'responds to tex_quote' do
    expect(:i_am_a_symbol.tex_quote).to eq 'i\\_am\\_a\\_symbol'
  end

  it 'return self :as_sym as a symbol but also a legal identifier' do
    expect(:i_am_a_symbol.as_sym).to eq :i_am_a_symbol
    expect(:'i-am-a_symbol'.as_sym).to eq :i_am_a_symbol
    expect(:'Four Score     and 7 years ago'.as_sym).to eq :four_score_and_7_years_ago
    expect(:four_score_and_7_years_ago.as_sym).to eq :four_score_and_7_years_ago
  end

  it 'as_str is the inverse of as_sym for simple cases' do
    expect('jack-in-the-box'.as_sym.as_str).to eq 'jack-in-the-box'
    expect('jack_in-the-box'.as_sym.as_str).to eq 'jack-in-the-box'
    expect('jack_in-the-box'.as_sym.as_str).to eq 'jack-in-the-box'
    expect(:four_score_and_7_years_ago.as_str).to eq 'four-score-and-7-years-ago'
    expect(:four_score_and_7_years_ago.as_str.as_sym).to eq :four_score_and_7_years_ago
  end
end
