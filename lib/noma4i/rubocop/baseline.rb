require 'rubocop'
require 'yaml'
require 'pathname'
require 'digest'

module Noma4i::RuboCop::Baseline
  def external_dependency_checksum
    Digest::SHA256.file(baseline_path).hexdigest if File.file?(baseline_path)
  end

  def on_new_investigation
    super
    @baseline_offenses = []
  end

  def on_investigation_end
    super
    count = @baseline_offenses.length
    expected = baseline_count
    @baseline_offenses.each { |node| add_offense(node) } if count > expected

    return unless count < expected

    add_offense(processed_source.buffer.line_range(1), message: "baseline for #{relative_path} is #{expected}, now #{count}: lower it in .rubocop/baseline.yml")
  end

  private

  def record_offense(node)
    @baseline_offenses << node
  end

  def baseline_count
    @baseline ||= File.file?(baseline_path) ? YAML.load_file(baseline_path) : {}

    @baseline.fetch(cop_name, {}).fetch(relative_path, 0)
  end

  def relative_path
    Pathname.new(processed_source.path).relative_path_from(Pathname.new(config.base_dir_for_path_parameters)).to_s
  end

  def baseline_path
    File.join(config.base_dir_for_path_parameters, '.rubocop/baseline.yml')
  end
end
