# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
require 'vcr'
require 'github_repo_stats'

VCR.configure do |config|
  # config.debug_logger = File.open('vcr-debug.log', 'w') # for debugging
  config.cassette_library_dir = 'spec/vcr'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = {
    record: :new_episodes,
    match_requests_on: %i[method path query body_as_json],
  }

  if ENV['GITHUB_ACCESS_TOKEN']
    masked_token = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    config.filter_sensitive_data(masked_token) { ENV['GITHUB_ACCESS_TOKEN'] }
  end

  config.before_record do |interaction|
    interaction.request.body.force_encoding 'UTF-8'
    request_content_type = interaction.request.headers['Content-Type'].first
    if request_content_type == 'application/json'
      interaction.request.body = JSON.pretty_generate(JSON.parse(interaction.request.body))
    end

    interaction.response.body.force_encoding 'UTF-8'
    response_content_type = interaction.response.headers['Content-Type'].first
    if response_content_type.include?('application/json')
      interaction.response.body = JSON.pretty_generate(JSON.parse(interaction.response.body))
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def capture(stream)
    begin
      stream = stream.to_s
      # rubocop:disable Security/Eval
      eval("$#{stream} = StringIO.new", nil, __FILE__, __LINE__) # $stdout = StringIO.new
      yield
      result = eval("$#{stream}", nil, __FILE__, __LINE__).string # $stdout
    ensure
      eval("$#{stream} = #{stream.upcase}", nil, __FILE__, __LINE__) # $stdout = STDOUT
      # rubocop:enable Security/Eval
    end

    result
  end
end
