require 'yaml'
require 'RedCloth'
require File.join(File.dirname(__FILE__), "../lib/attribute_accessors")
require File.join(File.dirname(__FILE__), "../lib/array_extensions")

class BlackList
  cattr_accessor :exact, :greedy, :initialized
  
  def self.initialize!
    load_words!
    trim_greedy_words!
    @@initialized = true
  end
  
  def self.deinitialize!
    @@exact, @@greedy = nil, nil
    @@initialized = false
  end
  
  def self.load_words!
    @@exact, @@greedy = YAML::load(IO.read(File.join(File.dirname(__FILE__), "../config/black_list.yml")))
  end
  
  def self.block?(text)
    initialize unless @@initialized
    greedy?(text) or exact?(text)
  end
  
  def self.exact?(text)
    initialize unless @@initialized
    return false if @@exact.nil?
    @@exact.each do |word|
      return true if exact_match?(text, word)
    end
    false
  end
  
  def self.greedy?(text)
    initialize unless @@initialized
    return false if @@greedy.nil?
    @@greedy.each do |word|
      return true if greedy_match?(text, word)
    end
    false
  end
  
  def self.highlight(text)
    return text if text !~ /\S/
    initialize unless @@initialized
    
    highlighted_text = text
    @@exact.each do |word|
      highlighted_text = highlighted_text.gsub(/\b(#{word})\b/i, '*\1*')
    end unless @@exact.nil?
    
    @@greedy.each do |word|
      highlighted_text = highlighted_text.gsub(/(#{word})+/i, '*\1*')
    end unless @@greedy.nil?
    
    RedCloth.new(highlighted_text).to_html
  end
  
  # Removes words that are supersets of other @@greedy words.
  # For example, "assassin" would be removed if it was a
  # @@greedy word and another @@greedy word, "ass" existed.
  def self.trim_greedy_words!
    @@greedy.each do |word|
      @@greedy.delete_if{ |other_word| other_word.match(word) && word != other_word }
    end
  end
  
  protected
    def self.exact_match?(text, word)
      text =~ /\b#{word}\b/i
    end
    
    def self.greedy_match?(text, word)
      text =~ /(#{word})+/i
    end
end