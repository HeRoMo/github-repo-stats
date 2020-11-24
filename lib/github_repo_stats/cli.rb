# frozen_string_literal: true

require 'thor'
require 'github_repo_stats/client'

module GithubRepoStats
  #
  # GithubRepoStats CLI
  #
  class CLI < Thor
    desc 'stats', 'aggregate reporsitory stats'
    method_option :repo, type: :string, aliases: '-r', required: true, desc: "repository's owner/repo"
    method_option :term, type: :string, aliases: '-t', required: true, desc: 'term of aggregate [yyyy-mm-dd..yyyy-mm-dd]'
    def stats
      repo = options[:repo]
      term = options[:term]
      client = GithubRepoStats::Client.new
      result = client.stats_of_repo(repo, term)
      pp result
    rescue StandardError => e
      warn e.message
      warn e.backtrace
    end

    def self.exit_on_failure?
      true
    end
  end
end
