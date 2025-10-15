# frozen_string_literal: true

require 'bundler/setup'
require 'groove'
require 'webmock/rspec'
require 'tempfile'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Clean up test files after each test
  config.after do
    temp_config = File.expand_path('~/.config/groove/config.yaml')
    temp_tokens = File.expand_path('~/.config/groove/tokens.json')

    File.delete(temp_config) if File.exist?(temp_config)
    File.delete(temp_tokens) if File.exist?(temp_tokens)
  end
end

# Mock configuration for tests
class TestConfiguration
  attr_accessor :spotify_client_id, :spotify_client_secret, :spotify_redirect_uri, :debug, :log_level

  def initialize
    @spotify_client_id = 'test_client_id'
    @spotify_client_secret = 'test_client_secret'
    @spotify_redirect_uri = 'http://localhost:8080/callback'
    @debug = false
    @log_level = 'info'
  end
end

# Test version of Authentication that uses plain JSON for testing
class TestAuthentication < Groove::Authentication
  private

  def save_tokens(token)
    FileUtils.mkdir_p(File.dirname(@tokens_path))

    token_data = {
      'access_token' => token.token,
      'refresh_token' => token.refresh_token,
      'expires_at' => token.expires_at,
      'token_type' => token.token_type,
      'scope' => token.params['scope']
    }

    File.write(@tokens_path, JSON.generate(token_data))
  end

  def load_tokens
    return {} unless File.exist?(@tokens_path)

    JSON.parse(File.read(@tokens_path))
  rescue JSON::ParserError => e
    raise Error, "Failed to load tokens: #{e.message}"
  end
end
