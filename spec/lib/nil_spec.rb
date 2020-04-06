require 'spec_helper'
require 'fat_core/nil'

describe NilClass do
  it 'should respond to entitle' do
    expect(nil.entitle).to eq ''
  end

  it 'should respond to tex_quote' do
    expect(nil.tex_quote).to eq ''
  end

  it 'should respond to commas' do
    expect(nil.commas).to eq ''
  end
end
