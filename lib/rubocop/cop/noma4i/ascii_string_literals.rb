require 'rubocop'

class RuboCop::Cop::Noma4i::AsciiStringLiterals < RuboCop::Cop::Base
  extend RuboCop::Cop::AutoCorrector

  MSG = 'Write the non-ASCII character `%<char>s` as a Unicode escape (`\\u%<code>s`).'
  NON_ASCII = /[^\x00-\x7F]/
  ESCAPED = /\\u(?:\{(\h+)\}|(\h{4}))/
  SINGLE_QUOTED_MSG = 'A Unicode escape inside single quotes is printed literally: use double quotes.'
  ESCAPES = { '"' => '\\"', '\\' => '\\\\', "\n" => '\\n', "\t" => '\\t', "\r" => '\\r', "\e" => '\\e' }.freeze

  def on_str(node)
    return if node.parent&.type?(:dstr, :dsym, :xstr, :regexp)
    return if percent_word_array?(node.parent)
    return check_single_quoted_escape(node) if single_quoted_escape?(node)

    match = node.source.match(NON_ASCII)

    return unless match

    add_offense(node, message: message_for(match[0])) do |corrector|
      corrector.replace(node, double_quoted(node.value)) if rewritable?(node)
    end
  end

  def on_dstr(node)
    return if node.heredoc?

    match = node.source.match(NON_ASCII)

    return unless match

    add_offense(node, message: message_for(match[0])) do |corrector|
      node.children.select(&:str_type?).each do |part|
        next unless part.source.match?(NON_ASCII)

        if double_quote_semantics?(node)
          corrector.replace(part, part.source.gsub(NON_ASCII) { |char| escape(char) })
        elsif rewritable?(part)
          corrector.replace(part, double_quoted(part.value))
        end
      end
    end
  end

  def on_array(node)
    return unless percent_word_array?(node)

    match = node.source.match(NON_ASCII)

    return unless match

    add_offense(node, message: message_for(match[0])) do |corrector|
      corrector.replace(node, "[#{node.children.map { |word| double_quoted(word.value) }.join(', ')}]")
    end
  end

  def on_sym(node)
    match = node.source.match(NON_ASCII)

    add_offense(node, message: message_for(match[0])) if match
  end

  private

  def percent_word_array?(node)
    node&.array_type? && node.percent_literal?(:string)
  end

  def single_quoted_escape?(node)
    opener = node.loc.respond_to?(:begin) ? node.loc.begin&.source.to_s : ''

    (opener == "'" || opener.start_with?('%q')) && node.value.match?(ESCAPED)
  end

  def check_single_quoted_escape(node)
    add_offense(node, message: SINGLE_QUOTED_MSG) do |corrector|
      decoded = node.value.gsub(ESCAPED) { (Regexp.last_match(1) || Regexp.last_match(2)).to_i(16).chr(Encoding::UTF_8) }

      corrector.replace(node, double_quoted(decoded))
    end
  end

  def message_for(char)
    format(MSG, char: char, code: escape(char).delete_prefix('\\u'))
  end

  def rewritable?(node)
    return false if node.heredoc? || node.loc.begin.nil?

    node.value.valid_encoding?
  end

  def double_quote_semantics?(node)
    opener = node.loc.begin&.source.to_s

    opener == '"' || opener.match?(/\A%[QW]?[^a-zA-Z0-9]\z/)
  end

  def double_quoted(value)
    body = value.each_char.with_index.map { |char, index| literal_char(char, value[index + 1]) }.join

    "\"#{body}\""
  end

  def literal_char(char, following)
    return escape(char) if char.match?(NON_ASCII)
    return ESCAPES.fetch(char) if ESCAPES.key?(char)
    return '\\#' if char == '#' && following.to_s.match?(/[{@$]/)
    return format('\\x%02X', char.ord) if char.ord < 32 || char.ord == 127

    char
  end

  def escape(char)
    code = char.ord

    code > 0xFFFF ? "\\u{#{code.to_s(16).upcase}}" : format('\\u%04X', code)
  end
end
