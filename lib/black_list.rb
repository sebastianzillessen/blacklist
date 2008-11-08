require 'yaml'
require 'RedCloth'
require 'singleton'

class BlackList
  include Singleton
  attr_accessor :exact, :greedy
  
  def self.method_missing(method, *args)
    self.instance.send(method, *args) unless method == :instance
  end
  
  def initialize
    load_words!
    trim_greedy_words!
  end
  
  def load_words!
    @exact, @greedy = YAML::load(IO.read(File.join(File.dirname(__FILE__), "../config/black_list.yml")))
  end
  
  def block?(text)
    greedy?(text) or exact?(text)
  end
  
  def exact?(text)
    check(text, :exact, @exact)
  end
  
  def greedy?(text)
    check(text, :greedy, @greedy)
  end
  
  def highlight(text)
    return text if text !~ /\S/
    
    text = highlight_words!(text, :exact, @exact)
    text = highlight_words!(text, :greedy, @greedy)
    
    RedCloth.new(text).to_html
  end
  
  # Removes words that are supersets of other @greedy words.
  # For example, "assassin" would be removed if it was a
  # @greedy word and another @greedy word, "ass" existed.
  def trim_greedy_words!
    @greedy.each do |word|
      @greedy.delete_if{ |other_word| other_word.match(word) && word != other_word }
    end
  end
  
  protected
    def highlight_words!(text, kind, words)
     words = (kind == :greedy ? @greedy : @exact)
      
      words.each do |word|
        if kind == :greedy
          text.gsub!(/(#{word})+/i, '*\1*')
        else
          text.gsub!(/\b(#{word})\b/i, '*\1*')
        end
      end unless words.nil?
      text
    end
    
    def check(text, kind, words)
      return false if words.nil?
      words.each do |word|
        return true if (kind == :greedy ? greedy_match?(text, word) : exact_match?(text, word))
      end
      false
    end
    
    def exact_match?(text, word)
      text =~ /\b#{word}\b/i
    end
    
    def greedy_match?(text, word)
      text =~ /(#{word})+/i
    end
end