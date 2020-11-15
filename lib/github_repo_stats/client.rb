# frozen_string_literal: true

require 'active_support/core_ext'
require_relative './github/api'
require_relative './github/graphql'

#
# <Description>
#
class GithubRepoStats::Client
  #
  # <Description>
  #
  # @param [<Type>] repo <description>
  # @param [<Type>] term <description>
  #
  # @return [<Type>] <description>
  #
  def exec(repo, term) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    review_counts = Hash.new(0) # レビューした数
    authors = Hash.new(0) # PRのオーサーの数
    # 結果の集計
    after = nil
    loop do # rubocop:disable Metrics/BlockLength
      result = GithubRepoStats::Github::Api::Client.query(
        GithubRepoStats::Github::Graphql::Query,
        variables: { query: "repo:#{repo} type:pr is:merged created:#{term}", after: after },
      )
      pr_nodes = result.data.search.edges.map(&:node)
      break if pr_nodes.count.zero?

      puts pr_nodes.count
      pr_nodes.each do |pr|
        commenters = Set.new
        pr_auther = pr.author.login
        authors[pr_auther] += 1
        comment_nodes = pr.comments.edges.map(&:node)
        comment_nodes.each do |comment|
          comment_author = comment.author.login
          commenters << comment_author if comment_author != pr_auther
        end
        review_nodes = pr.reviews.edges.map(&:node)
        review_nodes.each do |review|
          comment_author = review.author.login
          commenters << comment_author if comment_author != pr_auther
        end
        commenters.each do |commenter|
          review_counts[commenter] += 1
        end
      end
      after = result.data.search.edges.last.cursor
    end

    {
      authors: authors,
      review_counts: review_counts
    }
  end
end
