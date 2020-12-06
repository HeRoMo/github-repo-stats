# GithubRepoStats

A cli tool to aggregate activities in Github repository, by using Github graphql api.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'github_repo_stats', git: 'https://github.com/HeRoMo/github-repo-stats'
```

And then execute:

    $ bundle install

## Usage

### Aggregate activities of a repository

    $ GITHUB_ACCESS_TOKEN=<your token> github-repo-stats repo --repo <owner/repo> --start-month YYYY-MM

### Aggregate activities of a organigation (or owner).

    $ GITHUB_ACCESS_TOKEN=<your token> github-repo-stats org --repo <owner/repo> --start-month YYYY-MM

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HeRoMo/github-repo-stats.

## References

- [github/graphql\-client: A Ruby library for declaring, composing and executing GraphQL queries](https://github.com/github/graphql-client)
- [GraphQL API Explorer \| GitHub Developer Guide](https://developer.github.com/v4/explorer/)
- [Github API v4にgraphql\-client gemを使ってアクセスする \- Qiita](https://qiita.com/skuroki@github/items/eecc454edb2ac984be25)
- [GitHubのレビュー活動を見える化したかった\. 初めに \| by Tomoya Komiyama \| スタディスト開発ブログ \| Medium](https://medium.com/studist-dev/github-pr-analysis-d7cc51e76973)
