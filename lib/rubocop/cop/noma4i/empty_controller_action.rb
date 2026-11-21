require 'rubocop'

class RuboCop::Cop::Noma4i::EmptyControllerAction < RuboCop::Cop::Base
  include RuboCop::Cop::VisibilityHelp
  include RuboCop::Cop::RangeHelp
  extend RuboCop::Cop::AutoCorrector

  MSG = 'Remove the empty action `%<name>s`: Rails renders its template without it.'

  def on_def(node)
    return unless node.body.nil? && node.arguments.empty?
    return unless controller?(node)
    return unless node_visibility(node) == :public
    return unless template?(node.method_name)

    add_offense(node.loc.keyword.join(node.loc.name), message: format(MSG, name: node.method_name)) do |corrector|
      corrector.remove(removal_range(node))
    end
  end

  private

  def controller?(node)
    klass = node.each_ancestor(:class).first

    klass && klass.identifier.short_name.to_s.end_with?('Controller')
  end

  def template?(action)
    path = processed_source.file_path.to_s
    match = path.match(%r{(.*)/app/controllers/(.+)_controller\.rb\z})

    return false unless match

    Dir.glob(File.join(match[1], 'app/views', match[2], "#{action}.*")).any?
  end

  def removal_range(node)
    first_line = node.first_line
    first_line -= 1 while comment_line?(first_line - 1)
    last_line = node.last_line
    last_line += 1 if blank_line?(last_line + 1) && (first_line == 1 || blank_line?(first_line - 1))

    buffer = processed_source.buffer

    range_between(buffer.line_range(first_line).begin_pos, buffer.line_range(last_line).end_pos + 1)
  end

  def comment_line?(line)
    return false if line < 1

    processed_source.lines[line - 1].strip.start_with?('#')
  end

  def blank_line?(line)
    return false if line < 1 || line > processed_source.lines.size

    processed_source.lines[line - 1].strip.empty?
  end
end
