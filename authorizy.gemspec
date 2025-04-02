# frozen_string_literal: true

require_relative 'lib/authorizy/version'

Gem::Specification.new do |spec|
  spec.author = 'Washington Botelho'
  spec.description = 'A JSON based Authorization.'
  spec.email = 'wbotelhos@gmail.com'
  spec.extra_rdoc_files = Dir['CHANGELOG.md', 'LICENSE', 'README.md']
  spec.files = `git ls-files lib`.split("\n")
  spec.homepage = 'https://github.com/wbotelhos/authorizy'
  spec.license = 'MIT'
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.name = 'authorizy'
  spec.summary = 'A JSON based Authorization.'
  spec.version = Authorizy::VERSION

  spec.add_dependency('activesupport')
end
