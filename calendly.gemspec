# frozen_string_literal: true

require_relative 'lib/calendly/version'

Gem::Specification.new do |spec|
  spec.name          = 'calendly'
  spec.version       = Calendly::VERSION
  spec.authors       = ['Kenji Koshikawa']
  spec.email         = ['koshikawa2009@gmail.com']

  spec.description   = 'Client for accessing Calendly APIs'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/koshilife/calendly-api-ruby-client'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/koshilife/calendly-api-ruby-client'
  spec.metadata['changelog_uri'] = "#{spec.metadata['source_code_uri']}/blob/master/CHANGELOG.md"
  spec.metadata['documentation_uri'] = "https://www.rubydoc.info/gems/calendly/#{spec.version}"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'oauth2', '~> 1.4.4'
  spec.add_runtime_dependency 'zeitwerk', '~> 2.3.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'codecov', '~> 0.1.17'
  spec.add_development_dependency 'minitest', '~> 5.14.0'
  spec.add_development_dependency 'minitest-reporters', '~> 1.4.2'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'simplecov', '~> 0.18.5'
  spec.add_development_dependency 'webmock', '~> 3.7.6'
end
