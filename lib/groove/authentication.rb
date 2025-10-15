# frozen_string_literal: true

require 'oauth2'
require 'json'
require 'fileutils'
require 'openssl'
require 'base64'

module Groove
  class Authentication
    class Error < Groove::Error; end
    class TokenExpiredError < Error; end
    class AuthenticationError < Error; end

    SPOTIFY_AUTH_URL = 'https://accounts.spotify.com/authorize'
    SPOTIFY_TOKEN_URL = 'https://accounts.spotify.com/api/token'
    REDIRECT_URI = 'http://127.0.0.1:8080/callback'
    SCOPE = 'playlist-modify-public playlist-modify-private user-read-private'

    def initialize(config)
      @config = config
      @client_id = config.class.config.spotify_client_id
      @client_secret = config.class.config.spotify_client_secret
      @tokens_path = File.expand_path('~/.config/groove/tokens.json')
      @encryption_key = derive_encryption_key
    end

    def login
      client = OAuth2::Client.new(
        @client_id,
        @client_secret,
        site: 'https://accounts.spotify.com',
        authorize_url: '/authorize',
        token_url: '/api/token'
      )

      auth_url = client.auth_code.authorize_url(
        redirect_uri: REDIRECT_URI,
        scope: SCOPE
      )

      puts 'Please visit this URL to authorize the application:'
      puts auth_url
      puts "\nAfter authorization, you'll be redirected to a localhost URL."
      puts "Copy the 'code' parameter from the URL and paste it here:"

      print 'Authorization code: '
      code = STDIN.gets.chomp

      begin
        token = client.auth_code.get_token(code, redirect_uri: REDIRECT_URI)
        save_tokens(token)
        puts '✅ Successfully authenticated with Spotify!'
        true
      rescue OAuth2::Error => e
        raise AuthenticationError, "Authentication failed: #{e.message}"
      end
    end

    def logout
      if File.exist?(@tokens_path)
        File.delete(@tokens_path)
        puts '✅ Logged out successfully'
      else
        puts 'ℹ️  No active session found'
      end
    end

    def status
      if authenticated?
        tokens = load_tokens
        expires_at = Time.at(tokens['expires_at'])

        if expired?
          puts '❌ Authentication expired'
          false
        else
          puts '✅ Authenticated with Spotify'
          puts "   Expires: #{expires_at.strftime('%Y-%m-%d %H:%M:%S')}"
          true
        end
      else
        puts '❌ Not authenticated'
        false
      end
    end

    def authenticated?
      File.exist?(@tokens_path) && !expired?
    end

    def expired?
      return true unless File.exist?(@tokens_path)

      tokens = load_tokens
      Time.now.to_i >= tokens['expires_at']
    end

    def access_token
      return nil unless authenticated?

      tokens = load_tokens

      if expired?
        refresh_tokens
        tokens = load_tokens
      end

      tokens['access_token']
    end

    private

    def save_tokens(token)
      FileUtils.mkdir_p(File.dirname(@tokens_path))

      token_data = {
        'access_token' => token.token,
        'refresh_token' => token.refresh_token,
        'expires_at' => token.expires_at,
        'token_type' => token.params['token_type'] || 'Bearer',
        'scope' => token.params['scope']
      }

      encrypted_data = encrypt(JSON.generate(token_data))
      File.write(@tokens_path, encrypted_data)
    end

    def load_tokens
      return {} unless File.exist?(@tokens_path)

      encrypted_data = File.read(@tokens_path)
      decrypted_data = decrypt(encrypted_data)
      JSON.parse(decrypted_data)
    rescue JSON::ParserError, OpenSSL::Cipher::CipherError => e
      raise Error, "Failed to load tokens: #{e.message}"
    end

    def refresh_tokens
      tokens = load_tokens
      refresh_token = tokens['refresh_token']

      return unless refresh_token

      client = OAuth2::Client.new(
        @client_id,
        @client_secret,
        site: 'https://accounts.spotify.com',
        token_url: '/api/token'
      )

      begin
        token = client.refresh_token.get_token(refresh_token)
        save_tokens(token)
      rescue OAuth2::Error => e
        raise TokenExpiredError, "Token refresh failed: #{e.message}"
      end
    end

    def derive_encryption_key
      # Simple key derivation - in production, use a more secure method
      key = Digest::SHA256.digest("#{@client_secret}#{ENV.fetch('USER', nil)}")
      key[0, 32] # Use first 32 bytes for AES-256
    end

    def encrypt(data)
      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.encrypt
      cipher.key = @encryption_key
      iv = cipher.random_iv
      cipher.iv = iv

      encrypted = cipher.update(data) + cipher.final
      Base64.encode64(iv + encrypted)
    end

    def decrypt(encrypted_data)
      data = Base64.decode64(encrypted_data)

      cipher = OpenSSL::Cipher.new('AES-256-CBC')
      cipher.decrypt
      cipher.key = @encryption_key
      cipher.iv = data[0, 16] # First 16 bytes are IV

      encrypted = data[16..-1]
      cipher.update(encrypted) + cipher.final
    end
  end
end
