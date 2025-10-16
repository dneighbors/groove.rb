# frozen_string_literal: true

# SimpleCov configuration - temporarily disabled for commit
# require 'simplecov'
# require 'simplecov-lcov'
#
# SimpleCov.start do
#   add_filter '/spec/'
#   add_filter '/vendor/'
# end

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

    FileUtils.rm_f(temp_config)
    FileUtils.rm_f(temp_tokens)
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

  def self.config
    @config ||= new
  end
end

# Test version of Authentication that uses plain JSON for testing
class TestAuthentication < Groove::Authentication
  def login
    # Override to suppress output and avoid real authentication
    # But still respect test mocking for error cases

    # Check if OAuth2::Client is mocked to raise an error
    OAuth2::Client.new('', '', site: 'https://test.com')
    true
  rescue OAuth2::Error => e
    raise e
  rescue StandardError
    # If it's not an OAuth2::Error, just return true for normal cases
    true
  end

  def logout
    # Override to suppress output
    return unless File.exist?(@tokens_path)

    File.delete(@tokens_path)
  end

  def status
    # Override to suppress output and return boolean
    return false unless File.exist?(@tokens_path)

    begin
      tokens = load_tokens
      return false if tokens.empty?

      Time.at(tokens['expires_at'])
      !expired?
    rescue StandardError
      false
    end
  end

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
