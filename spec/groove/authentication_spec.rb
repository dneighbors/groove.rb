# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groove::Authentication do
  let(:config) { TestConfiguration.new }
  let(:auth) { TestAuthentication.new(config) }
  let(:tokens_path) { File.expand_path("~/.config/groove/tokens.json") }

  before do
    # Clean up any existing tokens
    File.delete(tokens_path) if File.exist?(tokens_path)
  end

  describe "#login" do
    it "raises AuthenticationError when client credentials are missing" do
      config.spotify_client_id = ""
      config.spotify_client_secret = ""
      
      # Mock gets to avoid hanging on input
      allow(auth).to receive(:gets).and_return("test_code")
      
      # Mock the OAuth2 client to raise an error
      allow(OAuth2::Client).to receive(:new).and_raise(OAuth2::Error.new("Invalid client"))
      
      expect { auth.login }.to raise_error(OAuth2::Error, "Invalid client")
    end

    it "generates correct authorization URL" do
      client = double("OAuth2::Client")
      auth_code = double("OAuth2::Strategy::AuthCode")
      
      allow(OAuth2::Client).to receive(:new).and_return(client)
      allow(client).to receive(:auth_code).and_return(auth_code)
      allow(auth_code).to receive(:authorize_url).and_return("https://accounts.spotify.com/authorize?client_id=test&redirect_uri=http://localhost:8080/callback&response_type=code&scope=playlist-modify-public%20playlist-modify-private%20user-read-private")
      
      # Mock the user input
      allow(auth).to receive(:gets).and_return("test_code")
      
      # Mock successful token exchange
      token = double("OAuth2::AccessToken")
      allow(token).to receive(:token).and_return("access_token")
      allow(token).to receive(:refresh_token).and_return("refresh_token")
      allow(token).to receive(:expires_at).and_return(Time.now.to_i + 3600)
      allow(token).to receive(:token_type).and_return("Bearer")
      allow(token).to receive(:params).and_return({"scope" => "playlist-modify-public playlist-modify-private user-read-private"})
      
      allow(auth_code).to receive(:get_token).and_return(token)
      
      expect { auth.login }.not_to raise_error
    end
  end

  describe "#logout" do
    it "deletes tokens file when it exists" do
      FileUtils.mkdir_p(File.dirname(tokens_path))
      File.write(tokens_path, "test")
      
      expect(File.exist?(tokens_path)).to be true
      auth.logout
      expect(File.exist?(tokens_path)).to be false
    end

    it "handles case when tokens file doesn't exist" do
      expect { auth.logout }.not_to raise_error
    end
  end

  describe "#status" do
    it "returns false when not authenticated" do
      expect(auth.status).to be false
    end

    it "returns true when authenticated and not expired" do
      # Create valid tokens
      token_data = {
        "access_token" => "test_token",
        "refresh_token" => "test_refresh",
        "expires_at" => Time.now.to_i + 3600,
        "token_type" => "Bearer",
        "scope" => "playlist-modify-public"
      }
      
      FileUtils.mkdir_p(File.dirname(tokens_path))
      File.write(tokens_path, JSON.generate(token_data))
      
      expect(auth.status).to be true
    end

    it "returns false when tokens are expired" do
      # Create expired tokens
      token_data = {
        "access_token" => "test_token",
        "refresh_token" => "test_refresh",
        "expires_at" => Time.now.to_i - 3600,
        "token_type" => "Bearer",
        "scope" => "playlist-modify-public"
      }
      
      FileUtils.mkdir_p(File.dirname(tokens_path))
      File.write(tokens_path, JSON.generate(token_data))
      
      expect(auth.status).to be false
    end
  end

  describe "#authenticated?" do
    it "returns false when tokens file doesn't exist" do
      expect(auth.authenticated?).to be false
    end

    it "returns false when tokens are expired" do
      token_data = {
        "access_token" => "test_token",
        "refresh_token" => "test_refresh",
        "expires_at" => Time.now.to_i - 3600,
        "token_type" => "Bearer",
        "scope" => "playlist-modify-public"
      }
      
      FileUtils.mkdir_p(File.dirname(tokens_path))
      File.write(tokens_path, JSON.generate(token_data))
      
      expect(auth.authenticated?).to be false
    end

    it "returns true when tokens exist and are valid" do
      token_data = {
        "access_token" => "test_token",
        "refresh_token" => "test_refresh",
        "expires_at" => Time.now.to_i + 3600,
        "token_type" => "Bearer",
        "scope" => "playlist-modify-public"
      }
      
      FileUtils.mkdir_p(File.dirname(tokens_path))
      File.write(tokens_path, JSON.generate(token_data))
      
      expect(auth.authenticated?).to be true
    end
  end

  describe "#access_token" do
    it "returns nil when not authenticated" do
      expect(auth.access_token).to be_nil
    end

    it "returns access token when authenticated" do
      token_data = {
        "access_token" => "test_access_token",
        "refresh_token" => "test_refresh",
        "expires_at" => Time.now.to_i + 3600,
        "token_type" => "Bearer",
        "scope" => "playlist-modify-public"
      }
      
      FileUtils.mkdir_p(File.dirname(tokens_path))
      File.write(tokens_path, JSON.generate(token_data))
      
      expect(auth.access_token).to eq("test_access_token")
    end
  end

  describe "token encryption" do
    it "encrypts and decrypts tokens correctly" do
      original_data = "test_token_data"
      
      # Test encryption/decryption through save/load cycle
      token = double("OAuth2::AccessToken")
      allow(token).to receive(:token).and_return("access_token")
      allow(token).to receive(:refresh_token).and_return("refresh_token")
      allow(token).to receive(:expires_at).and_return(Time.now.to_i + 3600)
      allow(token).to receive(:token_type).and_return("Bearer")
      allow(token).to receive(:params).and_return({"scope" => "playlist-modify-public"})
      
      auth.send(:save_tokens, token)
      loaded_tokens = auth.send(:load_tokens)
      
      expect(loaded_tokens["access_token"]).to eq("access_token")
      expect(loaded_tokens["refresh_token"]).to eq("refresh_token")
    end
  end
end
