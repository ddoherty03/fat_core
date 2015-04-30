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

  describe "class methods" do
    it "should be able to generate a random string" do
      ss = String.random(100)
      expect(ss.class).to eq String
      expect(ss.size).to eq 100
    end
  end

  describe "instance methods" do
    it "should be able to convert a digital date to iso form" do
      expect("20140521".digdate2iso).to eq '2014-05-21'
    end

    it "should wrap a short string" do
      expect("hello, world".wrap).to eq "hello, world"
    end

    it "should wrap a long string" do
      @getty.wrap.split("\n").each {|l| expect(l.length).to be <= 70}
    end

    it "should wrap a long string with a hangining indent" do
      @getty.wrap(70, 10).split("\n").each {|l| expect(l.length).to be <= 70}
      @getty.wrap(70, 10).split("\n")[1..-1].each do |l|
        expect(l).to match(/^          /)
      end
      second_line = ' ' * 10 + 'nent a new nation'
      third_line =  ' ' * 10 + 'e proposition'
      twenty_fourth_line = ' ' * 10 + 'eople, by the people, for the people'
      expect(@getty.wrap(70, 10).split("\n")[1]).to match(/^#{second_line}/)
      expect(@getty.wrap(70, 10).split("\n")[2]).to match(/^#{third_line}/)
      expect(@getty.wrap(70, 10).split("\n")[23]).to match(/^#{twenty_fourth_line}/)
    end

    it "should be able to quote special TeX characters" do
      expect("$10,000".tex_quote).to eq("\\$10,000")
      expect("would~~have".tex_quote).to eq("would\\textasciitilde{}\\textasciitilde{}have")
      expect("<hello>".tex_quote).to eq("\\textless{}hello\\textgreater{}")
      expect("{hello}".tex_quote).to eq("\\{hello\\}")
    end

    it "should be able to determine is it's a valid number" do
      expect('88'.number?).to be true
      expect('-88'.number?).to be true
      expect('8.008'.number?).to be true
      expect('-8.008'.number?).to be true
      expect('8.008e33'.number?).to be true
      expect('-8.008e33'.number?).to be true
      expect('0x8.008'.number?).to be false
      expect('hello world'.number?).to be false
    end

    it "should be able to convert a string to a regular expression" do
      re = "/hello((\s+)(world))?/".to_regexp
      expect(re.class).to eq Regexp
      expect(re.casefold?).to be true
      expect(re.multiline?).to be false

      re = "/hello((\s+)(world))?/Im".to_regexp
      expect(re.class).to eq Regexp
      expect(re.casefold?).to be false
      expect(re.multiline?).to be true

      # Works without /../ but no options possible
      re = "hello((\s+)(world))?".to_regexp
      expect(re.class).to eq Regexp
      expect(re.casefold?).to be false
      expect(re.multiline?).to be false
    end

    it "should be able to convert itself to a sym" do
      expect("joke".as_sym).to eq :joke
      expect("hello world".as_sym).to eq :hello_world
      expect("hello world   it's me".as_sym).to eq :hello_world_its_me
      expect("Street1".as_sym).to eq :street1
    end

    it "should do nothing in response to as_string" do
      expect("joke".as_string).to eq "joke"
      expect("hello world".as_string).to eq "hello world"
      expect("hello world   it's me".as_string)
        .to eq "hello world   it's me"
    end

    it "should be able to fuzzy match with another string" do
      expect("Hello, world".fuzzy_match('or')).to be_truthy
      expect("Hello, world".fuzzy_match('ox')).to be_falsy
    end

    it "should be able to match with another string containing re" do
      expect("Hello, world".matches_with('/or/')).to be_truthy
      expect("Hello, world".matches_with('/ox/')).to be_falsy
    end

    it "should be able to match with another string containing string" do
      expect("Hello, world".matches_with('or')).to be_truthy
      expect("Hello, world".matches_with('ox')).to be_falsy
    end

    it "should be able to fuzzy match space-separated parts" do
      expect("Hello world".fuzzy_match('hel or')).to be_truthy
      expect("Hello, world".fuzzy_match('hel ox')).to be_falsy
    end

    it "should be able to fuzzy match colon-separated parts" do
      expect("Hello:world".fuzzy_match('hel:or')).to be_truthy
      expect("Hello:world".fuzzy_match('hel:ox')).to be_falsy
    end

    it "should be able to fuzzy match colon-separated parts" do
      expect("Hello:world".fuzzy_match('hel:or')).to be_truthy
      expect("Hello:world".fuzzy_match('hel:ox')).to be_falsy
    end

    it "should return the matched text" do
      expect("Hello:world".fuzzy_match('hel')).to eq('Hel')
      expect("Hello:world".fuzzy_match('hel:or')).to eq('Hello:wor')
      expect("Hello:world".matches_with('/^h.*r/')).to eq('Hello:wor')
    end

    it "should ignore periods, commas, and apostrophes when matching" do
      expect("St. Luke's".fuzzy_match('st lukes')).to eq('St Lukes')
      expect("St Lukes".fuzzy_match('st. luke\'s')).to eq('St Lukes')
      expect("St Lukes, Inc.".fuzzy_match('st luke inc')).to eq('St Lukes Inc')
      expect("E*TRADE".fuzzy_match('etrade')).to eq('ETRADE')
    end

    it "should be able to properly capitalize a string as a title" do
      # Capitalize little words only at beginning and end
      expect("the cat in the hat".entitle).to eq('The Cat in the Hat')
      expect("dr".entitle).to eq('Dr')
      expect("cr".entitle).to eq('Cr')
      # Capitalize all consonants size if >= 3
      expect("tr".entitle).to eq('Tr')
      expect("trd".entitle).to eq('TRD')
      # Don't capitalize c/o
      expect("IBM c/o watson".entitle).to eq('Ibm c/o Watson')
      # Capitlaize p.o.
      expect("p.o. box 123".entitle).to eq('P.O. Box 123')
      # Don't capitalize ordinals
      expect("22nd of september".entitle).to eq('22nd of September')
      # Capitalize common abbrevs
      expect("US BANK".entitle).to eq('US Bank')
      expect("NW territory".entitle).to eq('NW Territory')
      # Leave word starting with numbers alone
      expect("apartment 33-B".entitle).to eq('Apartment 33-B')
      # Assume all consanants is an acronym
      expect("the cbs network".entitle).to eq('The CBS Network')
      # Capitalize both parts of a hyphenated word
      expect("the hitler-stalin pact".entitle).
        to eq('The Hitler-Stalin Pact')
    end

    it "should be able to compute its Levenshtein distance from another string" do
      expect('Something'.distance('Smoething')).to eq 1
      expect('Something'.distance('Smoething', block_size: 0)).to eq 2
      expect('Something'.distance('meSothing', block_size: 1)).to eq 4
      expect('Something'.distance('meSothing', block_size: 2)).to eq 2
      expect('SomethingElse'.distance('Encyclopedia')).to eq 10
      expect('SomethingElseUnrelated'.
              distance('EncyclopediaBritanica',
                       max_distance: 40)).to eq 21
      expect('SomethingElseUnrelated'.
              distance('EncyclopediaBritanica',
                       max_distance: 15)).to eq 15
    end
  end
end
