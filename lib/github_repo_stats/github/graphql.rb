# frozen_string_literal: true

require_relative './api'

module GithubRepoStats
  module Github
    module Graphql
      Query = Api::Client.parse <<-GRAPHQL
      query ($query: String!, $after: String) {
        search(type: ISSUE, query: $query, first: 100, after: $after) {
          edges {
            cursor
            node {
              ... on PullRequest {
                title
                author {
                  login
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
                id
              }
            }
          }
        }
      }
      GRAPHQL
    end
  end
end
