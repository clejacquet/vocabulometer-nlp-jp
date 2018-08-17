# encoding: utf-8

require 'set'

class JumanTokenizer
  class << self
    def init
      get_words { |words| @words = words }
      get_stopwords { |stopwords| @stopwords = stopwords }
    end

    def raw(input, stdin, stdout)
      stdin.syswrite(input + "\n")
      str = read {stdout.sysread(4096)}

      yield({
          processed: str.split("\n")
      })
    end

    def parse(input, stdin, stdout)
      stdin.syswrite(input + "\n")
      str = read {stdout.sysread(4096)}

      result = process(str)

      words = result[:tokens].map do |word|
        word[:raw]
      end

      offset = 0
      start_positions = words.map do |word|
        beg = input.index(word, offset)
        size = word.size

        offset = beg + size
        [beg, offset]
      end

      beg = 0
      inter_words = start_positions.map do |position|
        substr = input[beg...position[0]]
        beg = position[1]
        substr
      end

      inter_words.push input[beg..-1]

      yield({
          processed: {
              words: result[:tokens],
              interWords: inter_words,
              unrecognized: result[:unrecognized].to_a,
              unrecognizedRate: result[:unrecognizedRate]
          }
      })
    end


    private

    def get_stopwords
      File.open("stopwords.txt", "r:UTF-8") do |f|
        set = Set.new
        f.each_line do |line|
          set.add(line.gsub(/([^\r]*)\r?\n/, '\1'))
        end
        yield set
      end
    end

    def get_words
      levels = []

      (1..5).each do |i|
        File.open("jlpt/n#{i}.txt", "r:UTF-8") do |f|
          array = []
          f.each_line do |line|
            array.push line.gsub(/([^\r]*)\r?\n/, '\1')
          end
          levels.push(array)

          if levels.size == 5
            yield levels.flatten!.to_set
          end
        end
      end
    end

    def read
      final = ''
      while (str = yield)
        final += str
        if final.end_with?("EOS\n")
          break
        end
      end
      final.force_encoding('UTF-8')
    end

    def map_pos(pos)
      begin
        pos_id = Integer(pos)
      rescue
        pos_id = 1
      end

      pos_id
    end

    def process(str)
      tokens = str.split("\n").map do |line|
        if line.start_with?('@') or line.match('EOS')
          ''
        else
          items = line.split(' ')
          {
              value: items[0],
              lemma: items[2],
              pos: map_pos(items[4])
          }
        end
      end.delete_if { |token| token.empty? or token[:value].empty? or token[:pos] === 1 }

      non_stopwords = tokens
                          .reject { |token| @stopwords.include? token[:lemma] }
                          .map { |token| token[:lemma] }

      if non_stopwords.empty?
        return {
            words: [],
            unrecognized: [],
            unrecognizedRate: 0,
            tokens: []
        }
      end

      vocab = non_stopwords.reject { |token| not @words.include? token }

      words = vocab.to_set
      unrecognized = non_stopwords.to_set - words
      unrecognized_rate = 1.0 *  unrecognized.size / non_stopwords.size

      tokens.map! do |token|
        if vocab.include? token[:lemma]
          {
              raw: token[:value],
              lemma: token[:lemma]
          }
        else
          {
              raw: token[:value]
          }
        end
      end

      {
          words: words,
          unrecognized: unrecognized,
          unrecognizedRate: unrecognized_rate,
          tokens: tokens
      }
    end
  end
end



