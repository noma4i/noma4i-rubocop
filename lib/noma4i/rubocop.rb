require 'rubocop'
require 'lint_roller'
require 'pathname'
require_relative 'rubocop/version'

module Noma4i
  module RuboCop
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'noma4i-rubocop',
          version: VERSION,
          homepage: 'https://github.com/noma4i/noma4i-rubocop',
          description: 'Shared RuboCop rules.'
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../config/default.yml')
        )
      end
    end
  end
end

require 'rubocop/cop/noma4i'
Dir[File.expand_path('../rubocop/cop/noma4i/*.rb', __dir__)].sort.each { |path| require path }
