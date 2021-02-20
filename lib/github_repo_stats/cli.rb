# frozen_string_literal: true

require 'thor'
require 'github_repo_stats/client'
require 'active_support/core_ext/time'

module GithubRepoStats
  MONTH_REGEX = /\d{4}-\d{1,2}/.freeze
  #
  # GithubRepoStats CLI
  #
  class CLI < Thor
    class_option :verbose, type: :boolean, aliases: '-v', desc: 'verbose output'
    class_option :debug, type: :boolean, desc: 'output backtrace when error'

    desc 'repo', 'aggregate pulls of a reporsitory'
    method_option :repo, type: :string, aliases: '-r', required: true, desc: "repository's owner/repo"
    method_option(
      :'start-month', type: :string, aliases: '-s', required: true, banner: 'YYYY-MM', desc: 'start month of aggregate',
    )
    method_option :'end-month', type: :string, aliases: '-e', banner: 'YYYY-MM', desc: 'end month of aggregate'
    def repo
      repo = options[:repo]
      start_month = options[:'start-month']
      end_month = options[:'end-month'] || start_month

      client = GithubRepoStats::Client.new
      result = client.pulls_of_repo(repo, start_month, end_month)
      result.delete(:pull_requests) unless options[:verbose]
      puts JSON.pretty_generate(result)
    rescue StandardError => e
      warn "ERROR: #{e.message}"
      warn e.backtrace if options[:debug]
    end

    desc 'org', 'aggregate pulls par reporsitory of organization/owner'
    method_option :org, type: :string, aliases: '-o', required: true, desc: 'organization name or owner name'
    method_option(
      :'start-month', type: :string, aliases: '-s', required: true, banner: 'YYYY-MM', desc: 'start month of aggregate',
    )
    method_option :'end-month', type: :string, aliases: '-e', banner: 'YYYY-MM', desc: 'end month of aggregate'
    def org
      org = options[:org]
      start_month = options[:'start-month']
      end_month = options[:'end-month'] || start_month
      client = GithubRepoStats::Client.new
      result = client.pulls_of_org(org, start_month, end_month)
      result.transform_values { |repo| repo.delete('pull_requests') } unless options[:verbose]
      puts JSON.pretty_generate(result)
    rescue StandardError => e
      warn "ERROR: #{e.message}"
      warn e.backtrace if options[:debug]
    end

    desc 'user', 'aggregate user commits'
    method_option :user, type: :string, aliases: '-u', required: true, desc: 'user name'
    method_option(
      :'start-month', type: :string, aliases: '-s', required: true, banner: 'YYYY-MM', desc: 'start month of aggregate',
    )
    method_option :'end-month', type: :string, aliases: "-e", banner: 'YYYY-MM', desc: 'end month of aggregate'
    def user
      user_name = options[:user]
      start_month = options[:'start-month']
      end_month = options[:'end-month'] || start_month
      client = GithubRepoStats::Client.new
      result = client.user(user_name, start_month, end_month)
      puts JSON.pretty_generate(result)
    rescue StandardError => e
      warn "ERROR: #{e.message}"
      warn e.backtrace if options[:debug]
    end

    def self.exit_on_failure?
      true
    end
  end
end
