require_relative 'lib/noma4i/rubocop/version'

Gem::Specification.new do |spec|
  spec.name = 'noma4i-rubocop'
  spec.version = Noma4i::RuboCop::VERSION
  spec.summary = 'Shared RuboCop rules'
  spec.authors = ['noma4i']
  spec.homepage = 'https://github.com/noma4i/noma4i-rubocop'
  spec.license = 'MIT'
  spec.metadata['default_lint_roller_plugin'] = 'Noma4i::RuboCop::Plugin'
  spec.required_ruby_version = '>= 3.2'
  spec.files = Dir['lib/**/*.rb', 'config/default.yml', 'README.md']
  spec.add_dependency 'lint_roller'
  spec.add_dependency 'rubocop', '>= 1.72'
  spec.add_dependency 'rubocop-haml'
  spec.add_dependency 'rubocop-performance'
end
