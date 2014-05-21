require 'spec_helper'

describe String do
  before do
    #23456789012345678901234567890123456789012345678901234567890123456789|
    @getty = "\
Four score and seven years ago our fathers brought forth on this conti\
nent a new nation, conceived in liberty, and dedicated to the proposit\
ion that all men are created equal.  Now we are engaged in a great civ\
il war, testing whether that nation, or any nation, so conceived and s\
o dedicated, can long endure. We are met on a great battle-field of th\
at war. We have come to dedicate a portion of that field, as a final r\
esting place for those who here gave their lives that that nation migh\
t live. It is altogether fitting and proper that we should do this.  B\
ut, in a larger sense, we can not dedicate, we can not consecrate, we \
can not hallow this ground. The brave men, living and dead, who strugg\
led here, have consecrated it, far above our poor power to add or detr\
act. The world will little note, nor long remember what we say here, b\
ut it can never forget what they did here. It is for us the living, ra\
ther, to be dedicated here to the unfinished work which they who fough\
t here have thus far so nobly advanced. It is rather for us to be here\
 dedicated to the great task remaining before us--that from these hono\
red dead we take increased devotion to that cause for which they gave \
the last full measure of devotion--that we here highly resolve that th\
ese dead shall not have died in vain--that this nation, under God, sha\
ll have a new birth of freedom--and that government of the people, by \
the people, for the people, shall not perish from the earth."
    ##123456789012345678901234567890123456789012345678901234567890123456789|
    #     @getty = "\
    # Four score and seven years ago our fathers brought forth on this conti\
    #           nent a new nation, conceived in liberty, and dedicated to th\
    #           e proposition that all men are created equal.  Now we are en\
    #           gaged in a great civil war, testing whether that nation, or \
    #           any nation, so conceived and so dedicated, can long endure. \
    #           We are met on a great battle-field of that war. We have come\
    #            to dedicate a portion of that field, as a final resting pla\
    #           ce for those who here gave their lives that that nation migh\
    #           t live. It is altogether fitting and proper that we should d\
    #           o this.  But, in a larger sense, we can not dedicate, we can\
    #            not consecrate, we can not hallow this ground. The brave me\
    #           n, living and dead, who struggled here, have consecrated it,\
    #            far above our poor power to add or detract. The world will \
    #           little note, nor long remember what we say here, but it can \
    #           never forget what they did here. It is for us the living, ra\
    #           ther, to be dedicated here to the unfinished work which they\
    #            who fought here have thus far so nobly advanced. It is rath\
    #           er for us to be here dedicated to the great task remaining b\
    #           efore us--that from these honored dead we take increased dev\
    #           otion to that cause for which they gave the last full measur\
    #           e of devotion--that we here highly resolve that these dead s\
    #           hall not have died in vain--that this nation, under God, sha\
    #           ll have a new birth of freedom--and that government of the p\
    #           eople, by the people, for the people, shall not perish from \
    #           the earth."
    ##123456789012345678901234567890123456789012345678901234567890123456789|
  end

  it "should wrap a short string" do
    "hello, world".wrap.should == "hello, world"
  end

  it "should wrap a long string" do
    @getty.wrap.split("\n").each {|l| l.length.should <= 70}
  end

  it "should wrap a long string with a hangining indent" do
    @getty.wrap(70, 10).split("\n").each {|l| l.length.should <= 70}
    @getty.wrap(70, 10).split("\n")[1..-1].each do |l|
      l.should match(/^          /)
    end
    second_line = ' ' * 10 + 'nent a new nation'
    third_line =  ' ' * 10 + 'e proposition'
    twenty_fourth_line = ' ' * 10 + 'eople, by the people, for the people'
    @getty.wrap(70, 10).split("\n")[1].should match(/^#{second_line}/)
    @getty.wrap(70, 10).split("\n")[2].should match(/^#{third_line}/)
    @getty.wrap(70, 10).split("\n")[23].should match(/^#{twenty_fourth_line}/)
  end

  it "should be able to quote special TeX characters" do
    "$10,000".tex_quote.should eq("\\$10,000")
    "would~~have".tex_quote.should eq("would\\textasciitilde{}\\textasciitilde{}have")
    "<hello>".tex_quote.should eq("\\textless{}hello\\textgreater{}")
    "{hello}".tex_quote.should eq("\\{hello\\}")
  end

  it "should be able to fuzzy match with another string" do
    "Hello, world".fuzzy_match('or').should be_true
    "Hello, world".fuzzy_match('ox').should be_false
  end

  it "should be able to fuzzy match with another string containing re" do
    "Hello, world".matches_with('/or/').should be_true
    "Hello, world".matches_with('/ox/').should be_false
  end

  it "should be able to fuzzy match space-separated parts" do
    "Hello world".fuzzy_match('hel or').should be_true
    "Hello, world".fuzzy_match('hel ox').should be_false
  end

  it "should be able to fuzzy match colon-separated parts" do
    "Hello:world".fuzzy_match('hel:or').should be_true
    "Hello:world".fuzzy_match('hel:ox').should be_false
  end

  it "should be able to fuzzy match colon-separated parts" do
    "Hello:world".fuzzy_match('hel:or').should be_true
    "Hello:world".fuzzy_match('hel:ox').should be_false
  end

  it "should return the matched text" do
    "Hello:world".fuzzy_match('hel').should eq('Hel')
    "Hello:world".fuzzy_match('hel:or').should eq('Hello:wor')
    "Hello:world".matches_with('/^h.*r/').should eq('Hello:wor')
  end

  it "should ignore periods, commas, and apostrophes when matching" do
    "St. Luke's".fuzzy_match('st lukes').should eq('St Lukes')
    "St Lukes".fuzzy_match('st. luke\'s').should eq('St Lukes')
    "St Lukes, Inc.".fuzzy_match('st luke inc').should eq('St Lukes Inc')
  end
end
