#:title: BlackList RDoc Documentation
#
# = BlackList: dead simple content filtering
#
# This library is just a simple implementation of a blacklist to filter  content. 
# It comes with a set of default words for filtering in config/black_list.yml that 
# were obtained from http://www.noswearing.com. You can add or remove from the list 
# as necessary. It supports two types of filters currently--exact matches and greedy 
# matches.Exact matches will only match if the word is found on its own. Greedy 
# matches will find words nested within other words.  It will also work out of the 
# box as a Ruby on Rails plugin. Just drop it in vendor/plugins and it'll work.
#
# Usage is as follows:
# 
#   BlackList.block?("Stupid ass simple.")    => true
#   BlackList.block?("Squeaky clean.")        => false
#   BlackList.block?("Assassins!")            => false
# 
# You can also just search for particular sorts of matches:
# 
#   BlackList.greedy?("Stupid ass simple.")   => false
#   BlackList.exact?("Stupid ass simple.")    => true
# 
# It also supports highlighting flagged words:
# 
#   BlackList.highlight("Stupid ass simple.") => "<code><p>Stupid <strong>ass</strong> simple.</p></code>"
#   BlackList.highlight("Squeaky clean.")     => "<code><p>Squeaky clean.</p></code>"

require 'yaml'
require 'rubygems'
require 'RedCloth'
require 'singleton'

class BlackList
  include Singleton
  attr_accessor :exact, :greedy
  
  # Redirects all method calls made directly on BlackList to
  # BlackList.instance. For example:
  #
  #   BlackList.greedy?("foo") => BlackList.instance.greedy?("foo")
  def self.method_missing(method, *args) #:nodoc:
    self.instance.send(method, *args) unless method == :instance
  end
  
  # Loads blacklist words from black_list.yml and removes any
  # nested greedy words. This is always called implicitly due 
  # to the fact that BlackList is a Singleton. As such, there 
  # is only ever one instance.
  def initialize #:nodoc:
    load_words!
    trim_greedy_words!
  end
  
  # Check the supplied text to see whether it contains a blacklisted 
  # word and should be blocked.
  def block?(text)
    greedy?(text) or exact?(text)
  end
  
  # Check the supplied text to see whether it contains an exact
  # blacklisted word.
  def exact?(text)
    check(text, :exact, @exact)
  end
  
  # Check the supplied text to see whether it contains a greedy
  # blacklisted word.
  def greedy?(text)
    check(text, :greedy, @greedy)
  end
  
  # Get the supplied text in HTML format with any blacklisted
  # words bolded. Text is passed through a Textile markup
  # processor (RedCloth).
  def highlight(text)
    return text if text !~ /\S/
    
    text = highlight_words!(text, :exact, @exact)
    text = highlight_words!(text, :greedy, @greedy)
    
    RedCloth.new(text).to_html
  end
  
  private
    # Removes words that are supersets of other @greedy words.
    # For example, "assassin" would be removed if it was a
    # @greedy word and another @greedy word, "ass" existed.
    def trim_greedy_words!
      @greedy.each do |word|
        @greedy.delete_if{ |other_word| other_word.match(word) && word != other_word }
      end
    end
    
    # Return text with Textile markup for bolding all blacklisted
    # words of the designated match kind.
    def highlight_words!(text, kind, words)
      words.each do |word|
        if kind == :greedy
          text.gsub!(/(#{word})+/i, '[*\1*]')
        else
          text.gsub!(/\b(#{word})\b/i, '*\1*')
        end
      end unless words.nil?
      text
    end
    
    # Check the supplied text for any of the supplied words 
    # using the designated match kind.
    def check(text, kind, words) #:doc:
      return false if words.nil?
      words.each do |word|
        return true if (kind == :greedy ? greedy_match?(text, word) : exact_match?(text, word))
      end
      false
    end
    
    # Check for exact matches of word in the supplied text.
    def exact_match?(text, word) #:doc:
      text =~ /\b#{word}\b/i
    end
    
    # Check for greedy matches of word in the supplied text.
    def greedy_match?(text, word) #:doc:
      text =~ /(#{word})+/i
    end
    
    # Load all blacklisted words from black_list.yml and save
    # then in @exact and @greedy.
    def load_words!
      @exact, @greedy = YAML::load(File.read(File.join(File.dirname(__FILE__), "../config/black_list.yml")))
    end
end