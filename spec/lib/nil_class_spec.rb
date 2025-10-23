# frozen_string_literal: true

require 'spec_helper'
require 'fat_core/nil'

describe NilClass do
  it 'responds to entitle' do
    expect(nil.entitle).to eq ''
  end

  it 'responds to tex_quote' do
    expect(nil.tex_quote).to eq ''
  end

  it 'responds to commas' do
    expect(nil.commas).to eq ''
  end
end
