require 'rubocop'

class RuboCop::Cop::Noma4i::TemplateInstanceVariable < RuboCop::Cop::Base
  MSG = 'Read `%<name>s` as a local the controller exposes (`expose`/`render locals:`), not an instance variable.'

  def on_ivar(node)
    add_offense(node, message: format(MSG, name: node.children.first))
  end

  def on_ivasgn(node)
    add_offense(node.loc.name, message: format(MSG, name: node.children.first))
  end
end
