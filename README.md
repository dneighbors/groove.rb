# Groove.rb

A Ruby gem that syncs text lists of songs and artists to Spotify playlists, with future AI-powered music discovery capabilities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "groove"
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install groove
```

## Setup

### 1. Spotify App Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Note your Client ID and Client Secret
4. Add `http://localhost:8080/callback` to your app's redirect URIs

### 2. Configuration

Create a configuration file at `~/.config/groove/config.yaml`:

```yaml
spotify:
  client_id: "your_spotify_client_id_here"
  client_secret: "your_spotify_client_secret_here"
  redirect_uri: "http://localhost:8080/callback"

app:
  name: "groove"
  version: "0.1.0"
  debug: false

logging:
  level: "info"
```

Or set environment variables:

```bash
export SPOTIFY_CLIENT_ID="your_client_id"
export SPOTIFY_CLIENT_SECRET="your_client_secret"
```

### 3. Authentication

```bash
# Authenticate with Spotify
groove auth login

# Check authentication status
groove auth status

# Logout
groove auth logout
```

## Usage

```bash
# Show version
groove version

# Show help
groove help
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dneighbors/groove.rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).