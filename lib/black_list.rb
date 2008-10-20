require 'yaml'
require 'RedCloth'

class BlackList
  EXACT, GREEDY = YAML::load(File.open("./config/black_list.yml"))
  
  def self.block?(text)
    greedy?(text) or exact?(text)
  end
  
  def self.exact?(text)
    return false if EXACT.nil?
    EXACT.each do |word|
      return true if exact_match?(text, word)
    end
    false
  end
  
  def self.greedy?(text)
    return false if GREEDY.nil?
    GREEDY.each do |word|
      return true if greedy_match?(text, word)
    end
    false
  end
  
  def self.highlight(text)
    return text if text !~ /\S/
    
    highlighted_text = text
    EXACT.each do |word|
      highlighted_text = highlighted_text.gsub(/\b(#{word})\b/i, '*\1*')
    end unless EXACT.nil?
    
    GREEDY.each do |word|
      highlighted_text = highlighted_text.gsub(/(#{word})+/i, '*\1*')
    end unless GREEDY.nil?
    
    RedCloth.new(highlighted_text).to_html
  end
  
  protected    
    def self.exact_match?(text, word)
      text =~ /\b#{word}\b/i
    end
    
    def self.greedy_match?(text, word)
      text =~ /(#{word})+/i
    end
end