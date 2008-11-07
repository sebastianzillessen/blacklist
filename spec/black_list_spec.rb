require 'rubygems'
require 'RedCloth'
require File.join(File.dirname(__FILE__), '../lib/black_list')

describe BlackList do
  before(:all) do
    BlackList.initialize!
    @clean_phrase           = "This is a clean phrase."
    @greedy_phrase          = "Oh, fuck!"
    @exact_phrase           = "Let's kick some ass!"
    @nested_greedy_phrase   = "I have had it with these motherfucking snakes on this motherfucking plane!"
    @nested_exact_phrase    = "Watch out for the assassin!"
    @capcase_exact_phrase   = "Let's kick some AsS!"
    @capcase_greedy_phrase  = "Oh, FuCk!"
    @multiple_phrase        = "Oh, fuck! I have had it with these motherfucking snakes on this motherfucking plane!"
  end
  
  describe ".initialize!" do
    before(:each) do
      BlackList.deinitialize!
    end
    
    it "should load exact blacklist words" do
      lambda { BlackList.load_words! }.should change(BlackList, :exact)
    end
    
    it "should load greedy blacklist words" do
      lambda { BlackList.load_words! }.should change(BlackList, :greedy)
    end
    
    it "should set @@initialized to true" do
      lambda { BlackList.initialize! }.should change(BlackList, :initialized).to(true)
    end
  end
  
  describe ".deinitialize!" do
    before(:each) do
      BlackList.initialize!
    end
    
    it "should set @@exact to nil" do
      lambda { BlackList.deinitialize! }.should change(BlackList, :exact).to(nil)
    end
    
    it "should set @@greedy to nil" do
      lambda { BlackList.deinitialize! }.should change(BlackList, :greedy).to(nil)
    end
    
    it "should set @@initialized to false" do
      lambda { BlackList.deinitialize! }.should change(BlackList, :initialized).to(false)
    end
  end
  
  describe ".load_words!" do
    before(:each) do
      BlackList.deinitialize!
    end
    
    it "should load exact blacklist words" do
      lambda { BlackList.load_words! }.should change(BlackList, :exact)
    end
    
    it "should load greedy blacklist words" do
      lambda { BlackList.load_words! }.should change(BlackList, :greedy)
    end
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
      BlackList.exact?(BlackList.greedy.join(" ")).should be_false
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
      BlackList.highlight(@greedy_phrase).should =~ /((.*?)(<strong>.*?<\/strong>)){1}/
    end
    
    it "should return a set of <strong> tags for each blacklisted word" do
      BlackList.highlight(@multiple_phrase).should =~ /((.*?)(<strong>.*?<\/strong>)){3}/
    end
    
    it "should not return <strong> tags in a clean phrase" do
      BlackList.highlight(@clean_phrase).should_not =~ /((.*?)(<strong>.*?<\/strong>)){1}/
    end
    
    it "should not endlessly replace greedy words when a superset greedy word exists" do
      @nested_greedy_phrase = "A test where fag is mentioned along with faggot."
      BlackList.highlight(@nested_greedy_phrase).should =~ /((.*?)(<strong>.*?<\/strong>)){2}/
    end
  end
  
  describe ".trim_greedy_words!" do
    it "should remove words that are supersets of other greedy words" do
      BlackList.greedy = ["foo", "foobar", "foobarbaz"]
      BlackList.trim_greedy_words!
      BlackList.greedy.first.should == "foo"
      BlackList.greedy.size.should == 1
    end
  end
end
