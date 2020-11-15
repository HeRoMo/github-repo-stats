# frozen_string_literal: true

require 'active_support/core_ext'
require 'github_repo_stats/github/api'
require 'github_repo_stats/github/graphql'

module GithubRepoStats
  #
  # Github GraphQL Client
  #
  class Client
    #
    # Aggregate pull requests
    #
    # @param [String] repo Repository's owner/name
    # @param [String] term Term of aggregate [yyyy-mm-dd..yyyy-mm-dd]
    #
    # @return [Hash] { pull_requests: Array[Hash], author_counts: Hash, review_counts: Hash}
    #
    def exec(repo, term) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      pull_requests = []
      author_counts = Hash.new(0) # pull requests { author: count }
      review_counts = Hash.new(0) # reviewers { reviewer_name: count }
      # aggregate pull requests
      after = nil
      loop do
        result = GithubRepoStats::Github::Api::Client.query(
          GithubRepoStats::Github::Graphql::Query,
          variables: { query: "repo:#{repo} type:pr is:merged merged:#{term}", after: after },
        )
        pr_nodes = result.data.search.edges.map(&:node)
        pr_nodes.each do |pr|
          commenters = Set.new
          pr_auther = pr.author.login
          author_counts[pr_auther] += 1
          comment_nodes = pr.comments.edges.map(&:node)
          review_nodes = pr.reviews.edges.map(&:node)
          [*comment_nodes, *review_nodes].each do |comment|
            comment_author = comment.author.login
            commenters.add(comment_author) if comment_author != pr_auther && comment_author != 'github-actions'
          end
          commenters.each { |commenter| review_counts[commenter] += 1 }
          pull_requests.push(pull_request_summary(pr, commenters))
        end
        break unless result.data.search.page_info.has_next_page

        after = result.data.search.page_info.end_cursor
      end

      {
        pull_requests: pull_requests,
        author_counts: author_counts,
        review_counts: review_counts,
      }
    end

    private

    #
    # Extract pull request summary
    #
    # @param [<Type>] pull_request Pull Request Node
    # @param [Set[String]] commenters Commenters
    #
    # @return [Hash] Pull Resuest Summary
    #
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
