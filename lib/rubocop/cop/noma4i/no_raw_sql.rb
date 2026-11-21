require 'noma4i/rubocop/baseline'

module RuboCop::Cop::Noma4i
  class NoRawSql < RuboCop::Cop::Base
    include Noma4i::RuboCop::Baseline

    MSG = 'Express the query with ActiveRecord/Arel (style block: no SQL strings).'
    CONNECTION_METHODS = %i[execute select_all select_value select_values select_rows select_one exec_query].freeze
    QUERY_METHODS = %i[sanitize_sql_array find_by_sql].freeze
    FRAGMENT_METHODS = %i[where order reorder joins select group having pluck from].freeze

    def on_send(node)
      receiver = node.receiver
      connection_call = receiver&.send_type? && receiver.method_name == :connection && CONNECTION_METHODS.include?(node.method_name)
      arel_call = receiver&.const_type? && receiver.const_name == 'Arel' && node.method_name == :sql
      fragment_call = FRAGMENT_METHODS.include?(node.method_name) || (node.method_name == :not && receiver&.send_type? && receiver.method_name == :where)
      string_argument = node.first_argument && %i[str dstr].include?(node.first_argument.type)

      return unless connection_call || arel_call || QUERY_METHODS.include?(node.method_name) || (fragment_call && string_argument)

      record_offense(node)
    end
    alias on_csend on_send

    def on_str(node)
      return unless node.heredoc? && node.loc.heredoc_end.source.strip == 'SQL'

      record_offense(node)
    end
    alias on_dstr on_str
  end
end
