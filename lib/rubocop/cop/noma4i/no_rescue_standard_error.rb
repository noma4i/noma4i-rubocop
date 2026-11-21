require 'noma4i/rubocop/baseline'

module RuboCop::Cop::Noma4i
  class NoRescueStandardError < RuboCop::Cop::Base
    include Noma4i::RuboCop::Baseline

    MSG = 'Rescue specific exceptions instead of StandardError.'

    def on_resbody(node)
      exceptions = node.children.first
      broad = exceptions.nil? || exceptions.children.any? do |exception|
        exception.const_type? && exception.const_name == 'StandardError'
      end
      record_offense(node.loc.keyword) if broad
    end
  end
end
