require 'rubocop'

class RuboCop::Cop::Noma4i::ControllerInstanceVariable < RuboCop::Cop::Base
  MSG = 'Pass `%<name>s` to the template as a local: `expose :%<local>s, -> { ... }` or `render locals:`, not an instance variable.'

  def on_ivasgn(node)
    name = node.children.first

    add_offense(node.loc.name, message: format(MSG, name: name, local: name.to_s.delete_prefix('@')))
  end
end
