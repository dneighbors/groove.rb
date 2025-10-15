# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groove::Configuration do
  let(:config_path) { File.expand_path('~/.config/groove/config.yaml') }

  before do
    # Clean up any existing config
    File.delete(config_path) if File.exist?(config_path)

    # Reset configuration to defaults
    Groove::Configuration.config.spotify_client_id = ''
    Groove::Configuration.config.spotify_client_secret = ''
    Groove::Configuration.config.spotify_redirect_uri = 'http://localhost:8080/callback'
    Groove::Configuration.config.debug = false
    Groove::Configuration.config.log_level = 'info'
  end

  describe 'initialization' do
    it 'loads configuration from file when it exists' do
      config_data = {
        'spotify' => {
          'client_id' => 'file_client_id',
          'client_secret' => 'file_client_secret',
          'redirect_uri' => 'http://localhost:8080/callback'
        },
        'app' => {
          'debug' => true
        },
        'logging' => {
          'level' => 'debug'
        }
      }

      FileUtils.mkdir_p(File.dirname(config_path))
      File.write(config_path, config_data.to_yaml)

      config = described_class.new
      expect(config.class.config.spotify_client_id).to eq('file_client_id')
      expect(config.class.config.spotify_client_secret).to eq('file_client_secret')
      expect(config.class.config.debug).to be true
      expect(config.class.config.log_level).to eq('debug')
    end

    it "uses environment variables when config file doesn't exist" do
      ENV['SPOTIFY_CLIENT_ID'] = 'env_client_id'
      ENV['SPOTIFY_CLIENT_SECRET'] = 'env_client_secret'

      config = described_class.new
      expect(config.class.config.spotify_client_id).to eq('env_client_id')
      expect(config.class.config.spotify_client_secret).to eq('env_client_secret')

      ENV.delete('SPOTIFY_CLIENT_ID')
      ENV.delete('SPOTIFY_CLIENT_SECRET')
    end

    it 'uses defaults when neither file nor environment variables exist' do
      # Ensure no config file exists
      File.delete(config_path) if File.exist?(config_path)

      # Clear environment variables
      ENV.delete('SPOTIFY_CLIENT_ID')
      ENV.delete('SPOTIFY_CLIENT_SECRET')

      config = described_class.new
      expect(config.class.config.spotify_client_id).to eq('')
      expect(config.class.config.spotify_client_secret).to eq('')
      expect(config.class.config.debug).to eq(false)
      expect(config.class.config.log_level).to eq('info')
    end
  end

  describe 'configuration settings' do
    let(:config) { described_class.new }

    it 'has spotify_client_id setting' do
      expect(config.class.config.spotify_client_id).to be_a(String)
    end

    it 'has spotify_client_secret setting' do
      expect(config.class.config.spotify_client_secret).to be_a(String)
    end

    it 'has spotify_redirect_uri setting' do
      expect(config.class.config.spotify_redirect_uri).to eq('http://localhost:8080/callback')
    end

    it 'has debug setting' do
      expect(config.class.config.debug).to be_a(TrueClass).or be_a(FalseClass)
    end

    it 'has log_level setting' do
      expect(config.class.config.log_level).to be_a(String)
    end
  end
end
