require 'json'
require 'set'

class JpSet
  def initialize
    @grammar = Set.new
    @vocab = Set.new
  end

  def add_grammar(rule)
    @grammar.add rule
  end

  def add_vocab(word)
    @vocab.add word
  end

  def clear
    @grammar.clear
    @vocab.clear
  end

  def to_json
    {
        :grammar => @grammar.to_a,
        :vocab => @vocab.to_a,
    }.to_json
  end
end