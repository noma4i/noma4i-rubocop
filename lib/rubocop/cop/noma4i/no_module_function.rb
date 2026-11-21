require 'noma4i/rubocop/baseline'

module RuboCop::Cop::Noma4i
  class NoModuleFunction < RuboCop::Cop::Base
    include Noma4i::RuboCop::Baseline

    MSG = 'Use service classes instead of module_function.'

    def on_send(node)
      record_offense(node) if node.receiver.nil? && node.method_name == :module_function
    end
  end
end
