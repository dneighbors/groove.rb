# frozen_string_literal: true

require_relative "lib/groove/version"

Gem::Specification.new do |spec|
  spec.name = "groove"
  spec.version = Groove::VERSION
  spec.authors = ["dneighbors"]
  spec.email = ["dneighbors@example.com"]

  spec.summary = "Sync text lists of songs/artists to Spotify playlists"
  spec.description = "A Ruby gem that syncs text lists of songs and artists to Spotify playlists, with future AI-powered music discovery capabilities."
  spec.homepage = "https://github.com/dneighbors/groove.rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dneighbors/groove.rb"
  spec.metadata["changelog_uri"] = "https://github.com/dneighbors/groove.rb/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "oauth2", "~> 2.0"
  spec.add_dependency "faraday", "~> 2.9"
  spec.add_dependency "dry-configurable", "~> 1.0"
  # spec.add_dependency "ruby_llm", "~> 0.1" # TODO: Add when available

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.19"
  spec.add_development_dependency "rubocop", "~> 1.57"
  spec.add_development_dependency "rubocop-rspec", "~> 2.25"
end

