# noma4i-rubocop

Add to `Gemfile`:

```ruby
gem 'noma4i-rubocop', github: 'noma4i/noma4i-rubocop', require: false
```

Add to `.rubocop.yml`:

```yaml
plugins:
  - noma4i-rubocop
  - rubocop-performance
  - rubocop-haml
```

## Disable a cop in a project

```yaml
Noma4i/NoRawSql:
  Enabled: false
```

Override any cop using its standard RuboCop configuration. List the two extension
plugins explicitly to load their rules and Haml parser.

For baseline-aware cops, `.rubocop/baseline.yml` maps cop names to paths and
allowed offense counts, relative to the project root:

```yaml
Noma4i/NoRawSql:
  app/models/example.rb: 1
```

To add a cop, add its Ruby file under `lib/rubocop/cop/noma4i/` and add its
configuration to `config/default.yml`. Files load automatically in sorted order.

| Old name | New name |
| --- | --- |
| Layout/EmptyLineBeforeReturn | Noma4i/EmptyLineBeforeReturn |
| Layout/EmptyLineBeforeImplicitReturn | Noma4i/EmptyLineBeforeImplicitReturn |
| Style/AsciiStringLiterals | Noma4i/AsciiStringLiterals |
| Style/AsciiOnlyComments | Noma4i/AsciiOnlyComments |
| Style/ControllerInstanceVariable | Noma4i/ControllerInstanceVariable |
| Style/TemplateInstanceVariable | Noma4i/TemplateInstanceVariable |
| Style/TemplateLocalAssignment | Noma4i/TemplateLocalAssignment |
| Style/EmptyControllerAction | Noma4i/EmptyControllerAction |
| Style/TemplateFileExtension | Noma4i/TemplateFileExtension |
| Style/NoRawSql | Noma4i/NoRawSql |
| Style/NoModuleFunction | Noma4i/NoModuleFunction |
| Style/NoRescueStandardError | Noma4i/NoRescueStandardError |
