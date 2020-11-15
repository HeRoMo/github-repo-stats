# frozen_string_literal: true

# 参考
# https://qiita.com/skuroki@github/items/eecc454edb2ac984be25
# https://developer.github.com/v4/explorer/
# https://github.com/github/graphql-client
# https://medium.com/studist-dev/github-pr-analysis-d7cc51e76973
require 'graphql/client'
require 'graphql/client/http'

module GithubRepoStats
  module Github
    module Api
      HTTP = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
        def headers(context)
          { 'Authorization' => "Bearer #{ENV['ACCESS_TOKEN']}" }
        end
      end
      Schema = GraphQL::Client.load_schema(HTTP)
      Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
    end
  end
end
