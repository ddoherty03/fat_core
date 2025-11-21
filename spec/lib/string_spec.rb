# frozen_string_literal: true

require 'spec_helper'
require 'fat_core/string'

describe String do
  describe 'class methods' do
    it 'generates a random string' do
      ss = described_class.random(100)
      expect(ss.class).to eq String
      expect(ss.size).to eq 100
    end
  end

  describe 'instance methods' do
    describe 'wrapping' do
      # 23456789012345678901234567890123456789012345678901234567890123456789|
      let(:getty) do
        "\
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
      end

      # 0000000000111111111122222222223333333333444444444455555555556666666666
      # 0123456789012345678901234567890123456789012345678901234567890123456789|
      # Four score and seven years ago our fathers brought forth on
      #          this continent a new nation, conceived in liberty, and
      #          dedicated to the proposition that all men are created
      #          equal. Now we are engaged in a great civil war, testing
      #          whether that nation, or any nation, so conceived and
      #          so dedicated, can long endure. We are met on a great
      #          battle-field of that war. We have come to dedicate a
      #          portion of that field, as a final resting place for
      #          those who here gave their lives that that nation might
      #          live. It is altogether fitting and proper that we should
      #          do this. But, in a larger sense, we can not dedicate,
      #          we can not consecrate, we can not hallow this ground.
      #          The brave men, living and dead, who struggled here,
      #          have consecrated it, far above our poor power to add
      #          or detract. The world will little note, nor long remember
      #          what we say here, but it can never forget what they
      #          did here. It is for us the living, rather, to be dedicated
      #          here to the unfinished work which they who fought here
      #          have thus far so nobly advanced. It is rather for us
      #          to be here dedicated to the great task remaining before
      #          us--that from these honored dead we take increased devotion
      #          to that cause for which they gave the last full measure
      #          of devotion--that we here highly resolve that these dead
      #          shall not have died in vain--that this nation, under
      #          God, shall have a new birth of freedom--and that government
      #          of the people, by the people, for the people, shall
      #          not perish from the earth.

      it 'wraps a short string' do
        expect('hello, world'.wrap).to eq 'hello, world'
      end

      it 'wraps a long string' do
        str = getty.wrap
        str.split("\n").each { |l| expect(l.length).to be <= 70 }
      end

      it 'wraps a long string with a hangining indent' do
        str = getty.wrap(70, 10)
        str.split("\n").each { |l| expect(l.length).to be <= 70 }
        expect(str.split("\n")[1..-1]).to all match(/^          /)
        second_line = ' ' * 10 + 'this continent a new nation'
        third_line =  ' ' * 10 + 'dedicated to the proposition'
        twenty_fourth_line = ' ' * 10 + 'shall not have died in vain'
        expect(str.split("\n")[1]).to match(/^#{second_line}/)
        expect(str.split("\n")[2]).to match(/^#{third_line}/)
        expect(str.split("\n")[23]).to match(/^#{twenty_fourth_line}/)
      end
    end

    it 'cleans up white space in a string' do
      expect('   string    here  '.clean).to eq 'string here'
    end

    describe 'numeric strings' do
      it 'converts a numeric string to a commified form' do
        expect('20140521'.commas).to eq '20,140,521'
        expect('20140521.556'.commas).to eq '20,140,521.556'
        expect('20140521.556'.commas(2)).to eq '20,140,521.56'
        expect('-20140521.556'.commas).to eq '-20,140,521.556'
        expect('+20140521.556'.commas).to eq '20,140,521.556'
        expect('+20140521.556e3'.commas).to eq '20,140,521,556'
        expect('3.141591828'.commas(11)).to eq '3.14159182800'
        expect('3.141591828'.commas(10)).to eq '3.1415918280'
        expect('3.141591828'.commas(9)).to eq '3.141591828'
        expect('3.141591828'.commas(8)).to eq '3.14159183'
        expect('3.141591828'.commas(7)).to eq '3.1415918'
        expect('3.141591828'.commas(6)).to eq '3.141592'
        expect('3.141591828'.commas(5)).to eq '3.14159'
        expect('3.141591828'.commas(4)).to eq '3.1416'
        expect('3.141591828'.commas(3)).to eq '3.142'
        expect('3.141591828'.commas(2)).to eq '3.14'
        expect('3.141591828'.commas(1)).to eq '3.1'
        expect('3.141591828'.commas(0)).to eq '3'
        expect('3.14'.commas(5)).to eq '3.14000'
        expect('6789345612.14'.commas).to eq '6,789,345,612.14'
        expect('6789345612.14'.commas(-1)).to eq '6,789,345,610'
        expect('6789345612.14'.commas(-2)).to eq '6,789,345,600'
        expect('6789345612.14'.commas(-3)).to eq '6,789,346,000'
        expect('6789345612.14'.commas(-4)).to eq '6,789,350,000'
        expect('6789345612.14'.commas(-5)).to eq '6,789,300,000'
        expect('6789345612.14'.commas(-6)).to eq '6,789,000,000'
        expect('6789345612.14'.commas(-7)).to eq '6,790,000,000'
        expect('6789345612.14'.commas(-8)).to eq '6,800,000,000'
        expect('6789345612.14'.commas(-9)).to eq '7,000,000,000'
        expect('6789345612.14'.commas(-10)).to eq '10,000,000,000'
        expect('6789345612.14'.commas(-11)).to eq '0'
      end

      it 'determines if it\'s a valid number' do
        expect('88'.number?).to be true
        expect('-88'.number?).to be true
        expect('8.008'.number?).to be true
        expect('-8.008'.number?).to be true
        expect('8.008e33'.number?).to be true
        expect('-8.008e33'.number?).to be true
        expect('hello world'.number?).to be false
      end
    end

    it 'converts a string to a regular expression' do
      # Ignores case by default
      re = "/hello((\s+)(world))?/".as_regexp
      expect(re.class).to eq Regexp
      expect(re.casefold?).to be true
      expect(re.multiline?).to be false
      expect(re.match?('Hello    WorlD')).to be true

      # Countermand ignore case with /.../I modifier
      re = "/hello((\s+)(world))?/Im".as_regexp
      expect(re.class).to eq Regexp
      expect(re.casefold?).to be false
      expect(re.multiline?).to be true
      expect(re.match?('Hello    WorlD')).to be false

      # Works without /../ but takes meta-characters literally, but still case insensitive
      str = "hello((\s+)(world))?"
      re = str.as_regexp
      expect(re.class).to eq Regexp
      expect(re.casefold?).to be true
      expect(re.multiline?).to be false
      expect(re.match?('hello    world')).to be false
      expect(re.match?(str)).to be true
      expect('Hello\b'.as_regexp).to eq(/Hello\\b/i)
      expect('Hello'.as_regexp).to eq(/Hello/i)
    end

    it 'converts metacharacters into Regexp' do
      "\\$()*+.<>?[]^{|}".chars.each do |c|
        re = c.as_regexp
        expect(re.class).to eq Regexp
        expect(re.match?(c)).to be true
      end
    end

    it 'converts itself to a sym' do
      expect('joke'.as_sym).to eq :joke
      expect('hello world'.as_sym).to eq :hello_world
      expect("hello world   it's me".as_sym).to eq :hello_world_its_me
      expect('Street1'.as_sym).to eq :street1
      expect('jack-in-the-box'.as_sym).to eq :jack_in_the_box
      expect('jack_in-the-box'.as_sym).to eq :jack_in_the_box
      expect('jack_in_the_box'.as_sym).to eq :jack_in_the_box
      expect('Jack in the Box'.as_sym).to eq :jack_in_the_box
      expect("Four Score  \t\n   and 7 years ago".as_sym).to eq :four_score_and_7_years_ago
    end

    it 'does nothing in response to as_str' do
      expect('joke'.as_str).to eq 'joke'
      expect('hello world'.as_str).to eq 'hello world'
      expect("hello world   it's me".as_str).to eq "hello world   it's me"
    end

    it 'properly capitalizes a string as a title' do
      # Capitalize little words only at beginning and end
      expect('the cat in the hat'.entitle).to eq('The Cat in the Hat')
      expect('dr'.entitle).to eq('Dr')
      expect('cr'.entitle).to eq('Cr')
      # Capitalize all consonants size if >= 3
      expect('tr'.entitle).to eq('Tr')
      expect('trd'.entitle).to eq('TRD')
      # Don't capitalize c/o
      expect('sherLOCK c/o watson'.entitle).to eq('Sherlock c/o Watson')
      # Capitlaize p.o.
      expect('p.o. box 123'.entitle).to eq('P.O. Box 123')
      # Don't capitalize ordinals
      expect('22nd of september'.entitle).to eq('22nd of September')
      # Capitalize common abbrevs
      expect('Us Bank'.entitle).to eq('US Bank')
      expect('nw territory'.entitle).to eq('NW Territory')
      # Leave word starting with numbers alone
      expect('apartment 33-B'.entitle).to eq('Apartment 33-B')
      # But not if the whole string is uppercase
      expect('THE ABC NETWORK'.entitle).to eq('The Abc Network')
      # Capitalize both parts of a hyphenated word
      expect('the hitler-stalin pact'.entitle).to eq('The Hitler-Stalin Pact')
    end

    it 'computes its Levenshtein distance from another string' do
      expect('Something'.distance('Smoething')).to eq 1
      expect('Something'.distance('meSothing')).to eq 4
      expect('SomethingElse'.distance('Encyclopedia')).to eq 11
      expect('SomethingElseUnrelated'.distance('EncyclopediaBritanica'))
        .to eq 11
      expect('SomethingElseUnrelated'.distance('EncyclopediaBritanica')).to eq 11
    end

    describe 'Quoting' do
      it 'quotes special TeX characters' do
        expect('$10,000'.tex_quote).to eq('\\$10,000')
        expect('would~~have'.tex_quote).to eq('would\\textasciitilde{}\\textasciitilde{}have')
        expect('<hello>'.tex_quote).to eq('\\textless{}hello\\textgreater{}')
        expect('{hello}'.tex_quote).to eq('\\{hello\\}')
      end
    end

    describe 'Fuzzy Matching' do
      it 'fuzzy matches with another string' do
        expect('Hello, world'.fuzzy_match('wor')).to be_truthy
        expect('Hello, world'.fuzzy_match('orl')).to be_truthy
        expect('Hello, world'.fuzzy_match('ox')).to be_falsy
      end

      it 'fuzzy matches space-separated parts' do
        expect('Hello world'.fuzzy_match('hel wor')).to be_truthy
        expect('Hello, world'.fuzzy_match('hel ox')).to be_falsy
      end

      it 'fuzzy matches colon-separated parts' do
        expect('Hello:world'.fuzzy_match('hel:wor')).to be_truthy
        expect('Hello:world'.fuzzy_match('hel :wor')).to be_truthy
        expect('Hello:world'.fuzzy_match('hel: wor')).to be_falsy
        expect('Hello:world'.fuzzy_match('hel:orld')).to be_falsy
        expect("Hello, 'world'".fuzzy_match('hel:wor')).to be_truthy
        expect('Hello "world"'.fuzzy_match('hel:world')).to be_truthy
      end

      it 'treats an internal `:stuff` as \bstuff.*' do
        expect('Hello, what is with the world?'.fuzzy_match('wha:wi:wor')).to be_truthy
        expect('Hello:world'.fuzzy_match('what:or')).to be_falsy
        expect('Hello, what=+&is (with) the world?'.fuzzy_match('wha:wi:wor')).to be_truthy
      end

      it 'treats an internal `stuff: ` as stuff\b.*' do
        expect('Hello, what is with the world?'.fuzzy_match('llo: th: :wor')).to be_truthy
        expect('Hello:world'.fuzzy_match('llox: ')).to be_falsy
        expect('Hello, what=+&is (with) the world?'.fuzzy_match('at: ith: the')).to be_truthy
      end

      it 'requires end-anchor for ending colon' do
        expect('Hello, to the world'.fuzzy_match('hel:world:')).to eq('Hello to the world')
        expect('Hello, to the world   '.fuzzy_match('hel:world:')).to eq('Hello to the world')
        expect('Hello, to the world today'.fuzzy_match('to:world:')).to be_nil
      end

      it 'requires start-anchor for leading colon' do
        expect('Hello, to the world'.fuzzy_match(':hel:the')).to eq('Hello to the')
        expect('   Hello, to the world'.fuzzy_match(':hel:the')).to eq('Hello to the')
        expect('Hello, to the world today'.fuzzy_match(':world:today')).to be_nil
      end

      it 'requires start-anchor and end-anchor for leading and ending colon' do
        expect('Hello, to the world'.fuzzy_match(':hel:world:')).to eq('Hello to the world')
        expect('Hello, to the world today'.fuzzy_match('hel:world:')).to be_falsy
      end

      it 'returns the matched text after match' do
        expect('Hello:world'.fuzzy_match('hel')).to eq('Hel')
        expect('Hello:world'.fuzzy_match('hel:wor')).to eq('Hello:wor')
        expect('Hello:world'.matches_with('/^h.*r/')).to eq('Hello:wor')
      end

      it 'ignores periods, commas, and apostrophes when matching' do
        expect("St. Luke's".fuzzy_match('st lukes')).to eq('St Lukes')
        expect('St Lukes'.fuzzy_match('st. luke\'s')).to eq('St Lukes')
        expect('St Lukes, Inc.'.fuzzy_match('st luke inc')).to eq('St Lukes Inc')
        expect('E*TRADE'.fuzzy_match('etrade')).to eq('ETRADE')
        # Does not recognize non-alphanumerics as start of string.
        expect('The 1 Dollar Store'.fuzzy_match('1 stor')).to be_truthy
        expect('The $1 Dollar Store'.fuzzy_match('$1 stor')).to be_falsy
      end

      it 'performs examples in documentation' do
        expect("St. Luke's".fuzzy_match('st lukes')).to eq('St Lukes')
        expect("St. Luke's Hospital".fuzzy_match('st lukes')).to eq('St Lukes')
        expect("St. Luke's Hospital".fuzzy_match('luk:hosp')).to eq('Lukes Hosp')
        expect("St. Luke's Hospital".fuzzy_match('st:spital')).to be_nil
        expect("St. Luke's Hospital".fuzzy_match('st spital')).to eq('St Lukes Hospital')
        expect("St. Luke's Hospital".fuzzy_match('st:laks')).to be_nil
        expect("St. Luke's Hospital".fuzzy_match(':lukes')).to be_nil
        expect("St. Luke's Hospital".fuzzy_match('lukes:hospital')).to eq('Lukes Hospital')
      end
    end

    describe '#matches_with' do
      it 'matches with another string containing a plain string' do
        expect('Hello, world'.matches_with('or')).to be_truthy
        expect('Hello, world'.matches_with('ox')).to be_falsy
      end

      it 'matches with another string containing re' do
        expect('Hello, world'.matches_with('/or/')).to be_truthy
        expect('Hello, world'.matches_with('/ox/')).to be_falsy
      end

      it 'performs examples in documentation with just strings' do
        expect("St. Luke's".matches_with('st lukes')).to eq('St Lukes')
        expect("St. Luke's Hospital".matches_with('st lukes')).to eq('St Lukes')
        expect("St. Luke's Hospital".matches_with('luk:hosp')).to eq('Lukes Hosp')
        expect("St. Luke's Hospital".matches_with('st:spital')).to be_nil
        expect("St. Luke's Hospital".matches_with('st spital')).to eq('St Lukes Hospital')
        expect("St. Luke's Hospital".matches_with('st:laks')).to be_nil
        expect("St. Luke's Hospital".matches_with(':lukes')).to be_nil
        expect("St. Luke's Hospital".matches_with('lukes:hospital')).to eq('Lukes Hospital')
      end

      it 'performs examples in documentation with regexes' do
        expect("St. Luke's".matches_with('/st\s*lukes/')).to eq('St Lukes')
        expect("St. Luke's Hospital".matches_with('/st lukes/')).to eq('St Lukes')
        expect("St. Luke's Hospital".matches_with('/luk.*\bhosp/')).to eq('Lukes Hosp')
        expect("St. Luke's Hospital".matches_with('/st(.*)spital\z/')).to eq('St Lukes Hospital')
        expect("St. Luke's Hospital".matches_with('/st spital/')).to be_nil
        expect("St. Luke's Hospital".matches_with('/st.*laks/')).to be_nil
        expect("St. Luke's Hospital".matches_with('/\Alukes/')).to be_nil
        expect("St. Luke's Hospital".matches_with('/lukes hospital/')).to eq('Lukes Hospital')
      end
    end
  end
end
