# frozen_string_literal: true

require 'github_repo_stats/github/api'

module GithubRepoStats
  module Github
    module Graphql
      Query = Api::Client.parse <<-'GRAPHQL'
      query ($query: String!, $after: String) {
        search(type: ISSUE, query: $query, first: 100, after: $after) {
          issueCount
          edges {
            cursor
            node {
              ... on PullRequest {
                id
                number
                title
                url
                createdAt
                mergedAt
                author {
                  login
                }
                commits {
                  totalCount
                }
                comments(first: 100) {
                  edges {
                    cursor
                    node {
                      author {
                        login
                      }
                      body
                    }
                  }
                  totalCount
                }
                reviews(first: 100) {
                  edges {
                    cursor
                    node {
                      author {
                        login
                      }
                      body
                    }
                  }
                  totalCount
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
      GRAPHQL
    end
  end
end
