require './lib/black_list'

describe BlackList do
  before(:all) do
    @clean_phrase           = "This is a clean phrase."
    @greedy_phrase          = "Oh, fuck!"
    @exact_phrase           = "Let's kick some ass!"
    @nested_greedy_phrase   = "I have had it with these motherfucking snakes on this motherfucking plane!"
    @nested_exact_phrase    = "Watch out for the assassin!"
    @capcase_exact_phrase   = "Let's kick some AsS!"
    @capcase_greedy_phrase  = "Oh, FuCk!"
    @multiple_phrase        = "Oh, fuck! I have had it with these motherfucking snakes on this motherfucking plane!"
  end
  
  describe ".block?" do
    it "should not block if no words are found" do
      BlackList.block?(@clean_phrase).should be_false
    end
    
    it "should find exact matches" do
      BlackList.block?(@exact_phrase).should be_true
    end
    
    it "should find greedy matches" do
      BlackList.block?(@greedy_phrase).should be_true
    end
  end
  
  describe ".exact?" do
    it "should only find words in the EXACT list" do
      BlackList.exact?(BlackList::GREEDY.join(" ")).should be_false
    end

    it "should find exact matches" do
      BlackList.exact?(@exact_phrase).should be_true
    end

    it "should not find nested words" do
      BlackList.exact?(@assassin_phrase).should be_false
    end

    it "should be case insensitive" do
      BlackList.exact?(@capcase_exact_phrase).should be_true
    end
  end

  describe ".greedy?" do
    it "should find exact words" do
      BlackList.greedy?(@greedy_phrase).should be_true
    end
    
    it "should find nested words" do
      BlackList.greedy?(@nested_greedy_phrase).should be_true
    end
    
    it "should be case insensitive" do
      BlackList.greedy?(@capcase_greedy_phrase).should be_true
    end
  end
  
  describe ".highlight" do
    it "should return HTML" do
      BlackList.highlight(@clean_phrase).should =~ /<p>.*?<\/p>/
    end
    
    it "should return a single set of <strong> tags when only one word is flagged" do
      BlackList.highlight(@greedy_phrase).should =~ /(<strong>.*?<\/strong>){1}/
    end
    
    it "should return a set of <strong> tags for each blacklisted word" do
      BlackList.highlight(@multiple_phrase).should =~ /(<strong>.*?<\/strong>){3}/
    end
    
    it "should not return <strong> tags in a clean phrase" do
      BlackList.highlight(@clean_phrase).should !~ /<strong>.*?<\/strong>/
    end
  end
end