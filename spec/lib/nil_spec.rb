require 'spec_helper'

describe NilClass do
  it "should respond to entitle" do
    expect(nil.entitle).to eq nil
  end

  it "should respond to tex_quote" do
    expect(nil.tex_quote).to eq ''
  end
end
