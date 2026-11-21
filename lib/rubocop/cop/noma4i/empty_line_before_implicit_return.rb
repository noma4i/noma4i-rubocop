require 'rubocop'

class RuboCop::Cop::Noma4i::EmptyLineBeforeImplicitReturn < RuboCop::Cop::Base
  extend RuboCop::Cop::AutoCorrector

  MSG = 'Separate the returned value from the earlier statements with one blank line.'

  VALUE_TYPES = %i[
    send csend block numblock itblock lvar ivar cvar gvar const
    str dstr sym dsym int float rational complex regexp array hash
    true false nil self yield super zsuper
  ].freeze
  VOID_METHODS = %i[raise fail].freeze

  def on_def(node)
    check(node)
  end

  def on_defs(node)
    check(node)
  end

  private

  def check(node)
    return if node.method?(:initialize)

    body = node.body

    return unless body&.begin_type? && body.children.size >= 2

    value = body.children.last

    return unless returned_value?(value)

    previous = body.children[-2]

    return if previous.last_line == value.first_line

    line = leading_line(value)

    return if blank_before?(line, previous)

    add_offense(value.source_range.with(end_pos: value.source_range.begin_pos + first_line_length(value))) do |corrector|
      corrector.insert_before(processed_source.buffer.line_range(line), "\n")
    end
  end

  def returned_value?(value)
    return value.children.any? if value.return_type?
    return complete_branches?(value) if value.if_type? || value.case_type? || value.case_match_type?
    return false unless VALUE_TYPES.include?(value.type)
    return false if value.send_type? && value.receiver.nil? && VOID_METHODS.include?(value.method_name)

    true
  end

  def complete_branches?(node)
    return false if node.if_type? && node.modifier_form?
    return node.else? if node.case_type? || node.case_match_type?

    else_branch = node.else_branch

    return false if else_branch.nil?

    !else_branch.if_type? || complete_branches?(else_branch)
  end

  def leading_line(value)
    line = value.first_line
    line -= 1 while comment_line?(line - 1)

    line
  end

  def comment_line?(line)
    return false if line < 1

    processed_source.comments.any? { |comment| comment.loc.line == line && own_line?(comment) }
  end

  def own_line?(comment)
    processed_source.lines[comment.loc.line - 1].strip.start_with?('#')
  end

  def blank_before?(line, previous)
    return true if line <= previous_end_line(previous)

    processed_source.lines[line - 2].strip.empty?
  end

  def previous_end_line(previous)
    heredoc_ends = previous.each_node(:str, :dstr, :xstr).select(&:heredoc?).map { |heredoc| heredoc.loc.heredoc_end.line }

    [previous.last_line, *heredoc_ends].max
  end

  def first_line_length(value)
    value.source.lines.first.chomp.length
  end
end
