# frozen_string_literal: true

require 'octokit'
require 'active_support/core_ext'

module GithubRepoStats
  module Github
    #
    # GGithub Rest API Client
    #
    class Rest
      PER_PAGE = 100
      SORT = 'committer-date'
      MONTH_REGEX = /\A\d{4}-\d{1,2}\Z/.freeze

      def initialize(github_token)
        @github_token = github_token
        @client = Octokit::Client.new
        @client.access_token = @github_token
      end

      #
      # fetch commits of a user,
      #
      # @param [String] user_name github user name
      # @param [String] start_month yyyy-mm
      # @param [String] end_month yyyy-mm
      #
      # @return [Hash] { total_count: , commits: }
      #
      def search_user_commits(user_name, start_month, end_month) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        page = 1
        total_count = 0
        raw_commits = []

        loop do
          term = term(start_month, end_month)
          results = search_commits(user_name, term, page)
          raw_commits.concat(results.items)
          total_count = results.total_count
          break if total_count <= page * PER_PAGE
          page += 1
        end
        commits = raw_commits.map do |item|
          "#{item.commit.committer.date.iso8601}, #{item.repository.full_name}, '#{item.commit.message.split("\n").first}', #{item.sha}" # rubocop:disable Layout/LineLength
        end

        { total_count: total_count, commits: commits, start_month: start_month, end_month: end_month }
      end

      private

      def search_commits(user_name, term, page = 1)
        @client.search_commits(
          "committer:#{user_name} merge:false committer-date:#{term}",
          sort: SORT,
          order: 'asc',
          per_page: PER_PAGE,
          page: page,
        )
      end

      def term(start_month, end_month = start_month)
        raise 'Invalid start-month' unless MONTH_REGEX.match?(start_month)
        raise 'Invalid end-month' unless MONTH_REGEX.match?(end_month)

        start_date = Date.parse("#{start_month}-01")
        end_date = Date.parse("#{end_month}-01").end_of_month

        "#{start_date}..#{end_date}"
      end
    end
  end
end
