# frozen_string_literal: true

require 'graphql/client'
require 'graphql/client/http'

module GithubRepoStats
  module Github
    module Api
      GITHUB_GRAPHQL_ENDPOINT = 'https://api.github.com/graphql'
      HTTP = GraphQL::Client::HTTP.new(GITHUB_GRAPHQL_ENDPOINT) do
        def headers(context)
          token = context[:access_token] || ENV['GITHUB_ACCESS_TOKEN']
          raise 'Missing GitHub access token' unless token

          { 'Authorization' => "Bearer #{token}" }
        end
      end
      Schema = GraphQL::Client.load_schema(HTTP)
      Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
    end
  end
end
