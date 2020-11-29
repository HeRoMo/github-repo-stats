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
    class_option :verbose, type: :boolean, aliases: '-v'

    desc 'repo', 'aggregate pulls of a reporsitory'
    method_option :repo, type: :string, aliases: '-r', required: true, desc: "repository's owner/repo"
    method_option :'start-month', type: :string, aliases: '-s', required: true, banner: 'YYYY-MM', desc: 'start month of aggregate'
    method_option :'end-month', type: :string, aliases: '-e', banner: 'YYYY-MM', default: 'start-month', desc: 'end month of aggregate'
    def repo
      repo = options[:repo]
      start_month = options[:'start-month']
      end_month = options[:'end-month'] || start_month
      term = term(start_month, end_month)

      client = GithubRepoStats::Client.new
      result = client.pulls_of_repo(repo, term)
      pp result
    rescue StandardError => e
      warn e.message
      warn e.backtrace if options[:verbose]
    end

    desc 'org', 'aggregate pulls par reporsitory of organization/owner'
    method_option :org, type: :string, aliases: '-o', required: true, desc: 'organization name or owner name'
    method_option :'start-month', type: :string, aliases: '-s', required: true, banner: 'YYYY-MM', desc: 'start month of aggregate'
    method_option :'end-month', type: :string, aliases: '-e', banner: 'YYYY-MM', default: 'start-month', desc: 'end month of aggregate'
    def org
      org = options[:org]
      start_month = options[:'start-month']
      end_month = options[:'end-month'] || start_month
      term = term(start_month, end_month)
      client = GithubRepoStats::Client.new
      result = client.pulls_of_org(org, term)
      pp result
    rescue StandardError => e
      warn e.message
      warn e.backtrace if options[:verbose]
    end

    def self.exit_on_failure?
      true
    end

    private

    def term(start_month, end_month)
      raise 'Invalid start-month' unless MONTH_REGEX.match?(start_month)
      raise 'Invalid end-month' unless MONTH_REGEX.match?(start_month)

      start_date = Date.parse("#{start_month}-01")
      end_date = Date.parse("#{end_month}-01").end_of_month

      "#{start_date}..#{end_date}"
    end
  end
end
