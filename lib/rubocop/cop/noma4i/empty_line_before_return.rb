require 'rubocop'

class RuboCop::Cop::Noma4i::EmptyLineBeforeReturn < RuboCop::Cop::Base
  extend RuboCop::Cop::AutoCorrector

  MSG = 'Add an empty line before `return` that follows other statements.'

  def on_return(node)
    statement = statement_for(node)
    body = statement.parent

    return unless body&.begin_type?

    index = body.children.index(statement)

    return if index.zero?

    previous = body.children[index - 1]

    return if guard_clause?(previous)
    return if previous.last_line == statement.first_line

    line = leading_line(statement)

    return if blank_before?(line, previous)

    add_offense(node.loc.keyword) do |corrector|
      corrector.insert_before(processed_source.buffer.line_range(line), "\n")
    end
  end

  private

  def statement_for(node)
    parent = node.parent

    return parent if parent&.if_type? && parent.modifier_form?

    node
  end

  def guard_clause?(node)
    return false unless node.if_type? && node.modifier_form?

    node.body&.type?(:return, :next, :break) || (node.body&.send_type? && node.body.method?(:raise))
  end

  def leading_line(node)
    line = node.first_line
    line -= 1 while comment_line?(line - 1)

    line
  end

  def comment_line?(line)
    return false if line < 1

    processed_source.lines[line - 1].strip.start_with?('#')
  end

  def blank_before?(line, previous)
    return true if line <= previous_end_line(previous)

    processed_source.lines[line - 2].strip.empty?
  end

  def previous_end_line(previous)
    heredoc_ends = previous.each_node(:str, :dstr, :xstr).select(&:heredoc?).map { |heredoc| heredoc.loc.heredoc_end.line }

    [previous.last_line, *heredoc_ends].max
  end
end
