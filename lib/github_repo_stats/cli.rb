# frozen_string_literal: true

require 'thor'
require 'github_repo_stats/client'

module GithubRepoStats
  #
  # GithubRepoStats CLI
  #
  class CLI < Thor
    desc 'stats', 'aggregate reporsitory stats'
    method_option :repo, type: :string, aliases: '-r', require: true, desc: "repository's owner/repo"
    method_option :term, type: :string, aliases: '-t', require: true, desc: 'term of aggregate [yyyy-mm-dd..yyyy-mm-dd]'
    def stats
      repo = options[:repo]
      term = options[:term]
      client = GithubRepoStats::Client.new
      result = client.exec(repo, term)
      pp result
    rescue StandardError => e
      warn e.message
      warn e.backtrace
    end
  end
end
