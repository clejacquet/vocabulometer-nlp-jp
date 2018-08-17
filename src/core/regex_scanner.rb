require_relative 'jp_set'

class RegexScanner
  def to_token_str(input)
    input
        .map { |token| token[0].to_s }
        .join ' '
  end

  def debug(input)
    input
        .map { |token| "#{token[1].to_s}_#{token[0].to_s}_#{token[3].to_s}"}
        .join ' '
  end

  def parse(input)
    set = JpSet.new

    puts debug(input)

    set.add_grammar :x_ha_x_desu if to_token_str(input) =~ /(?:\w+ )+HA (?:\w+ )+(?:DESU|(?:DE HA|JA) ARU MASU N)/
    set.add_grammar :desu_ka if to_token_str(input) =~ /(?:DESU|(?:DE HA|JA) ARU MASU N) KA/
    set.add_grammar :de_ha_arimasen if to_token_str(input) =~ /DE HA ARU MASU N/
    set.add_grammar :ja_arimasen if to_token_str(input) =~ /JA ARU MASU N/
    set.add_grammar :x_no_x if to_token_str(input) =~ /NOUN NO NOUN/
    set.add_grammar :x_no_desu if to_token_str(input) =~ /NO (?:DESU|(?:DE HA|JA) ARU MASU N)/
    set.add_grammar :kore if to_token_str(input) =~ /KORE/
    set.add_grammar :kono if to_token_str(input) =~ /KONO NOUN/
    set.add_grammar :asoko if to_token_str(input) =~ /ASOKO/

    set.add_grammar :x_wo_verb_masu if to_token_str(input) =~ /\w+ WO VERB MASU/
    set.add_grammar :verb_masu if to_token_str(input) =~ /VERB MASU(?:$| [^( N)](?:$| \w+)| N\w+)/
    set.add_grammar :verb_masen if to_token_str(input) =~ /VERB MASU N/
    set.add_grammar :verb_masu_ka if to_token_str(input) =~ /VERB MASU (?:N )?KA/

    input
        .delete_if { |token| not [:NOUN, :VERB, :ADVERB].include? token[3] }
        .map { |token| token[2] }
        .each { |token_val| set.add_vocab token_val }

    set.to_json
  end
end