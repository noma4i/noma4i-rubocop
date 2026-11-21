require 'rubocop'

class RuboCop::Cop::Noma4i::AsciiOnlyComments < RuboCop::Cop::Base
  extend RuboCop::Cop::AutoCorrector

  MSG = 'Use only ASCII in comments: replace `%<char>s`.'
  NON_ASCII = /[^\x00-\x7F]/
  REPLACEMENTS = {
    0x2014 => '-', 0x2013 => '-', 0x2012 => '-', 0x2011 => '-', 0x2010 => '-', 0x2212 => '-',
    0x2192 => '->', 0x2190 => '<-', 0x2194 => '<->', 0x21D2 => '=>', 0x2191 => 'up', 0x2193 => 'down',
    0x201C => '"', 0x201D => '"', 0x201E => '"', 0x00AB => '"', 0x00BB => '"',
    0x2018 => "'", 0x2019 => "'", 0x201A => "'",
    0x2026 => '...', 0x00B7 => '-', 0x2022 => '-', 0x203A => '>', 0x2039 => '<',
    0x00D7 => 'x', 0x2265 => '>=', 0x2264 => '<=', 0x2260 => '!=', 0x2248 => '~',
    0x00B0 => ' deg', 0x00A0 => ' ', 0x2009 => ' ', 0x202F => ' ', 0xFE0F => '',
    0x2713 => 'ok', 0x2714 => 'ok', 0x2705 => 'ok', 0x274C => 'no', 0x2717 => 'no', 0x25BC => 'v', 0x25B2 => '^',
    0x2318 => 'Cmd', 0x00E9 => 'e', 0x00A9 => '(c)'
  }.freeze

  def on_new_investigation
    processed_source.comments.each do |comment|
      match = comment.text.match(NON_ASCII)

      next unless match

      add_offense(comment, message: format(MSG, char: match[0])) do |corrector|
        corrector.replace(comment, comment.text.gsub(NON_ASCII) { |char| ascii_for(char) })
      end
    end
  end

  private

  def ascii_for(char)
    REPLACEMENTS.fetch(char.ord) { format('U+%04X', char.ord) }
  end
end
