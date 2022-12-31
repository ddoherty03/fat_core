require 'spec_helper'
require 'fat_core/symbol'

describe Symbol do
  it 'converts to a capitalized string' do
    expect(:i_am_a_symbol.entitle).to eq 'I Am a Symbol'
    expect(:i_am_a_symbol.as_string).to eq 'I Am a Symbol'
  end

  it 'responds to tex_quote' do
    expect(:i_am_a_symbol.tex_quote).to eq 'i\\_am\\_a\\_symbol'
  end

  it 'responds to :as_sym as identity' do
    expect(:i_am_a_symbol.as_sym).to eq :i_am_a_symbol
  end
end
