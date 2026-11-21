require 'rubocop'

class RuboCop::Cop::Noma4i::TemplateFileExtension < RuboCop::Cop::Base
  MSG = 'Name the template `%<name>s`: one `.haml` extension, no format part. Components use `haml_template`.'

  def on_new_investigation
    path = processed_source.file_path

    return unless path.end_with?('.html.haml')

    add_global_offense(format(MSG, name: File.basename(path).sub('.html.haml', '.haml')))
  end
end
