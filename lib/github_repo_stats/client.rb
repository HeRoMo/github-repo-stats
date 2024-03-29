# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'github_repo_stats/github/api'
require 'github_repo_stats/github/graphql'
require 'github_repo_stats/github/rest'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/time'

module GithubRepoStats
  #
  # Github GraphQL Client
  #
  class Client
    MONTH_REGEX = /\A\d{4}-\d{1,2}\Z/.freeze

    #
    # Aggregate pull requests of a repositories of a organization
    #
    # @param [String] org organization or owner name
    # @param [String] start_month YYYY-MM
    # @param [String] end_month YYYY-MM
    #
    # @return [Hash] Statistics of repositories of an organisation
    #
    def pulls_of_org(org, start_month, end_month)
      target = "org:#{org}"
      pulls_stats = pulls_stats(target, start_month, end_month)
      summary = summary_repos(pulls_stats)
      {
        repos: pulls_stats,
        summary: summary,
        start_month: start_month,
        end_month: end_month,
      }
    end

    #
    # Aggregate pull requests of a repository
    #
    # @param [String] repo Repository's owner/name
    # @param [String] term Term of aggregate [yyyy-mm-dd..yyyy-mm-dd]
    #
    # @return [Hash] { pull_requests: Array[Hash], author_counts: Hash, review_counts: Hash}
    def pulls_of_repo(repo, start_month, end_month = start_month)
      target = "repo:#{repo}"
      stats = pulls_stats(target, start_month, end_month)
      result = stats.values.first || {}
      result[:start_month] = start_month
      result[:end_month] = end_month
      result
    end

    def user(user_name, start_month, end_month)
      rest = ::GithubRepoStats::Github::Rest.new(ENV['GITHUB_ACCESS_TOKEN'])
      rest.search_user_commits(user_name, start_month, end_month)
    end

    private

    # Aggregate pull requests
    #
    # @param [String] target target repo: or org:
    # @param [String] start_month yyyy-mm
    # @param [String] end_month yyyy-mm
    #
    # @return [Hash] { repo: { pull_requests: Array[Hash], author_counts: Hash, review_counts: Hash}}
    #
    def pulls_stats(target, start_month, end_month)
      term_list = terms(start_month, end_month)
      stats = {}
      term_list.each do |term|
        stats = query_pulls(target, term, stats)
      end
      stats
    end

    #
    # query pullrequests
    #
    # @param [String] target target repo: or org:
    # @param [String] term Term of aggregate [yyyy-mm-dd..yyyy-mm-dd]
    #
    # @return [Hash] { repo: { pull_requests: Array[Hash], author_counts: Hash, review_counts: Hash}}
    #
    def query_pulls(target, term, stats = {}) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      # aggregate pull requests
      query = "#{target} type:pr is:merged merged:#{term}"
      after = nil
      loop do
        result = GithubRepoStats::Github::Api::Client.query(
          GithubRepoStats::Github::Graphql::Query,
          variables: { query: query, after: after },
        )
        pr_nodes = result.data.search.edges.map(&:node)
        pr_nodes.each do |pr|
          repo_name = pr.repository.name
          repo = stats[repo_name] || initial_repo

          commenters = Set.new
          pr_auther = pr.author.login
          repo[:author_counts][pr_auther] += 1
          comment_nodes = pr.comments.edges.map(&:node)
          review_nodes = pr.reviews.edges.map(&:node)
          [*comment_nodes, *review_nodes].each do |comment|
            comment_author = comment.author.login
            commenters.add(comment_author) if comment_author != pr_auther && comment_author != 'github-actions'
          end
          commenters.each { |commenter| repo[:review_counts][commenter] += 1 }
          repo[:pull_requests].push(pull_request_summary(pr, commenters))
          stats[repo_name] = repo
        end
        break unless result.data.search.page_info.has_next_page

        after = result.data.search.page_info.end_cursor
      end

      stats.with_indifferent_access
    end

    #
    # generate initial result object
    #
    # @return [Hash] initial result object
    #
    def initial_repo
      { pull_requests: [], author_counts: Hash.new(0), review_counts: Hash.new(0) }
    end

    #
    # Extract pull request summary
    #
    # @param [<Type>] pull_request Pull Request Node
    # @param [Set[String]] commenters Commenters
    #
    # @return [Hash] Pull Resuest Summary
    def pull_request_summary(pull_request, commenters) # rubocop:disable Metrics/MethodLength
      {
        number: pull_request.number,
        title: pull_request.title,
        auther: pull_request.author.login,
        created_at: pull_request.created_at,
        merged_at: pull_request.merged_at,
        commtis: pull_request.commits.total_count,
        comments: pull_request.comments.total_count,
        reviews: pull_request.reviews.total_count,
        reviewers: commenters.to_a.sort,
      }
    end

    #
    # sum repos stats
    #
    # @param [Hash] repos_stats stats of repos
    #
    # @return [Hash] summary of stats of repos
    #
    def summary_repos(repos_stats)
      summary = { author_counts: Hash.new(0), review_counts: Hash.new(0) }
      repos_stats.each_value do |repo|
        add_counts_to_summary(summary, repo, :author_counts)
        add_counts_to_summary(summary, repo, :review_counts)
      end
      summary
    end

    #
    # add counts to summary
    #
    # @param [Hash] summary summary of stats
    # @param [Hash] repo stats of a repo
    # @param [Symbol] count_name counter name
    #
    def add_counts_to_summary(summary, repo, count_name)
      summary_of_key = summary[count_name]
      repo_of_key = repo[count_name]
      repo_of_key.each { |key, value| summary_of_key[key] += value }
    end

    #
    # Generate term list
    #
    # @param [String] start_month YYYY-MM
    # @param [String] end_month YYYY-MM
    #
    # @return [Array[String]] terms
    #
    def terms(start_month, end_month = start_month)
      raise 'Invalid start-month' unless MONTH_REGEX.match?(start_month)
      raise 'Invalid end-month' unless MONTH_REGEX.match?(end_month)

      term_list = []
      beginning = Date.parse("#{start_month}-01")
      beginning_of_end_month = Date.parse("#{end_month}-01")

      while beginning <= beginning_of_end_month
        term_list.push("#{beginning}..#{beginning.end_of_month}")
        beginning = beginning.next_month
      end

      term_list
    end
  end
end
