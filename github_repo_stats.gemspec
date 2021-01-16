# frozen_string_literal: true

require_relative 'lib/github_repo_stats/version'

Gem::Specification.new do |spec|
  spec.name          = 'github_repo_stats'
  spec.version       = GithubRepoStats::VERSION
  spec.authors       = ['HeRoMo']
  spec.email         = ['dev@asterisk-works.jp']

  spec.summary       = 'Get stats of your Github repository'
  spec.description   = 'Get stats of your Github repository'
  spec.homepage      = 'https://github.com/HeRoMo/github-repo-stats'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/HeRoMo/github-repo-stats'
  spec.metadata['changelog_uri'] = 'https://github.com/HeRoMo/github-repo-stats/releases'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency('graphql-client')
  spec.add_dependency('octokit', '~> 4.0')
  spec.add_dependency('thor')
end
