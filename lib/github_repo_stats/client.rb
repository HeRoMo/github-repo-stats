# frozen_string_literal: true

require 'active_support/core_ext'
require 'github_repo_stats/github/api'
require 'github_repo_stats/github/graphql'
require 'active_support/core_ext/hash'

module GithubRepoStats
  #
  # Github GraphQL Client
  #
  class Client
    #
    # Aggregate pull requests of a repository
    #
    # @param [String] repo Repository's owner/name
    # @param [String] term Term of aggregate [yyyy-mm-dd..yyyy-mm-dd]
    #
    # @return [Hash] { pull_requests: Array[Hash], author_counts: Hash, review_counts: Hash}
    def pulls_of_repo(repo, term)
      target = "repo:#{repo}"
      result = query_pulls(target, term).values.first || {}
      result[:term] = term
      result
    end

    #
    # Aggregate pull requests of repositories of organization/owner
    #
    # @param [String] org organization/owner name
    # @param [String] term Term of aggregate [yyyy-mm-dd..yyyy-mm-dd]
    #
    # @return [Hash] { repo: { pull_requests: Array[Hash], author_counts: Hash, review_counts: Hash}}
    #
    def pulls_of_org(org, term)
      target = "org:#{org}"
      result = query_pulls(target, term)
      result[:term] = term
      result
    end

    private

    #
    # query pullrequests
    #
    # @param [String] target target repo: or org:
    # @param [String] term Term of aggregate [yyyy-mm-dd..yyyy-mm-dd]
    #
    # @return [Hash] { repo: { pull_requests: Array[Hash], author_counts: Hash, review_counts: Hash}}
    #
    def query_pulls(target, term) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      stats = {}
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
  end
end
