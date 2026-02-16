# frozen_string_literal: true

require_relative 'lib/r18n-core/version'

Gem::Specification.new do |s|
  s.name     = 'r18n-core'
  s.version  = R18n::VERSION

  s.summary     = 'I18n tool to translate your Ruby application.'
  s.description = <<-DESC
    R18n is a i18n tool to translate your Ruby application.
    It has nice Ruby-style syntax, filters, flexible locales, custom loaders,
    translation support for any classes, time and number localization, several
    user language support, agnostic core package with out-of-box support for
    Rails, Sinatra and desktop applications.
  DESC

  s.files = Dir['lib/**/*.rb', 'base/**/*.y{a,}ml', 'README.md', 'LICENSE', 'ChangeLog.md']
  s.extra_rdoc_files = ['README.md', 'LICENSE']

  s.authors  = ['Andrey Sitnik', 'Alexander Popov']
  s.email    = ['andrey@sitnik.ru', 'alex.wayfer@gmail.com']
  s.license  = 'LGPL-3.0'

  github_uri = "https://github.com/r18n/#{s.name}"

  s.homepage = github_uri

  s.metadata = {
    'rubygems_mfa_required' => 'true',
    'bug_tracker_uri' => "#{github_uri}/issues",
    'changelog_uri' => "#{github_uri}/blob/#{s.version}/ChangeLog.md",
    'documentation_uri' => "http://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'homepage_uri' => s.homepage,
    'source_code_uri' => github_uri
  }

  s.required_ruby_version = '>= 3.2', '< 3.5'

  s.add_dependency 'bigdecimal', '~> 4.0'
end
