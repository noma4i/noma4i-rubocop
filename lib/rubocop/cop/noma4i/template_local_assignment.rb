require 'rubocop'

class RuboCop::Cop::Noma4i::TemplateLocalAssignment < RuboCop::Cop::Base
  MSG = 'Do not assign `%<name>s` in a template: the controller passes it ready (`expose`/`render locals:`), ' \
        'a helper or a ViewComponent method computes it.'

  def on_lvasgn(node)
    return if node.parent&.type?(:mlhs, :args)

    add_offense(node.loc.name, message: format(MSG, name: node.children.first))
  end
end
