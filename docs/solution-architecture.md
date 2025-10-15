# groove.rb Architecture Document

**Project:** groove.rb
**Date:** 2025-10-15
**Author:** Developer

## Executive Summary

groove.rb is a Ruby CLI tool that automates Spotify playlist creation and management by syncing text lists of songs/artists. The tool uses Spotify's Web API for playlist operations, supports multiple file formats (CSV, plain text, JSON), and provides a command-line interface for easy automation. Future iterations will include AI conversation capabilities using RubyLLM for music discovery and playlist building.

The architecture follows a modular monolith pattern with clear separation of concerns: authentication, file parsing, Spotify API integration, playlist management, and CLI interface. The tool is designed as a Ruby gem for easy distribution and future integration into web applications.

## 1. Technology Stack and Decisions

### 1.1 Technology and Library Decision Table

| Category | Technology | Version | Rationale |
|----------|------------|---------|-----------|
| **Runtime** | Ruby | 3.4.6 | Current stable version with PRISM parser, managed via mise |
| **CLI Framework** | thor | 1.3.0 | Rails-like command structure, simple and well-maintained |
| **HTTP Client** | faraday | 2.9.0 | Flexible HTTP client with middleware support for OAuth2 |
| **OAuth2 Client** | oauth2 | 2.0.9 | Standard OAuth2 implementation for Spotify authentication |
| **File Parsing** | csv | built-in | Ruby's built-in CSV parser for CSV files |
| **YAML Parsing** | psych | built-in | Ruby's built-in YAML parser for configuration files |
| **JSON Parsing** | json | built-in | Ruby's built-in JSON parser for JSON files |
| **Progress Bars** | tty-progressbar | 0.18.2 | Terminal progress bars for long operations |
| **Color Output** | tty-color | 0.6.0 | Cross-platform color support with TTY detection |
| **Configuration** | dry-configurable | 1.0.1 | Type-safe configuration management |
| **Logging** | logger | built-in | Ruby's built-in logger with configurable levels |
| **Testing** | rspec | 3.12.0 | Ruby's standard testing framework |
| **Test Coverage** | simplecov | 0.22.0 | Code coverage reporting |
| **Mock HTTP** | webmock | 3.19.1 | HTTP request mocking for tests |
| **AI Integration** | ruby_llm | latest | AI conversation capabilities via OpenRouter |
| **File System** | fileutils | built-in | Ruby's built-in file operations |
| **Path Handling** | pathname | built-in | Ruby's built-in path manipulation |

## 2. Architecture Overview

### 2.1 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    groove.rb CLI Tool                       │
├─────────────────────────────────────────────────────────────┤
│  CLI Interface (thor)                                       │
│  ├── sync command                                           │
│  ├── update command                                         │
│  ├── auth command                                           │
│  └── config command                                         │
├─────────────────────────────────────────────────────────────┤
│  Core Modules                                               │
│  ├── Authentication Module (OAuth2)                        │
│  ├── File Parser Module (CSV/Text/JSON)                     │
│  ├── Spotify Client Module (API Integration)                 │
│  ├── Playlist Manager Module (CRUD Operations)              │
│  └── Configuration Module (YAML Config)                    │
├─────────────────────────────────────────────────────────────┤
│  External Integrations                                      │
│  ├── Spotify Web API                                        │
│  └── OpenRouter API (Future: AI Features)                  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Command Structure

```bash
groove sync <file> --playlist <name> [options]
groove update <file> --playlist <id> [options]
groove auth [--login|--logout|--status]
groove config [--set|--get|--list]
groove --version
groove --help
```

### 2.3 Data Flow

1. **Authentication Flow**: OAuth2 with Spotify → Store tokens securely
2. **File Processing**: Parse input file → Extract song/artist pairs
3. **Song Matching**: Search Spotify API → Fuzzy match songs
4. **Playlist Operations**: Create/update playlist → Add matched songs
5. **Feedback**: Report results → Show success/failure counts

## 3. Data Architecture

### 3.1 Configuration Data

**Location**: `~/.config/groove/config.yaml`

```yaml
# Configuration structure
spotify:
  client_id: "your_client_id"
  client_secret: "your_client_secret"
  redirect_uri: "http://localhost:8080/callback"

defaults:
  playlist_visibility: "private"
  duplicate_handling: "skip"
  output_format: "text"

cache:
  token_file: "~/.config/groove/tokens.json"
  playlist_cache: "~/.config/groove/playlists.json"
```

### 3.2 Input File Formats

**CSV Format**:
```csv
artist,song
"The Beatles","Hey Jude"
"Led Zeppelin","Stairway to Heaven"
```

**Plain Text Format**:
```
The Beatles - Hey Jude
Led Zeppelin - Stairway to Heaven
```

**JSON Format**:
```json
[
  {"artist": "The Beatles", "song": "Hey Jude"},
  {"artist": "Led Zeppelin", "song": "Stairway to Heaven"}
]
```

### 3.3 Cache Data

**Token Storage**: Encrypted JSON file with Spotify access/refresh tokens
**Playlist Cache**: Local cache of user's playlists for faster operations

## 4. Component and Integration Overview

### 4.1 Core Components

**Authentication Module**:
- OAuth2 flow implementation
- Token storage and refresh
- Secure credential management

**File Parser Module**:
- Multi-format file parsing (CSV, text, JSON)
- Input validation and error handling
- Song/artist extraction logic

**Spotify Client Module**:
- Web API integration
- Rate limiting handling
- Error response management

**Playlist Manager Module**:
- Playlist CRUD operations
- Song addition/removal
- Duplicate handling

**CLI Interface Module**:
- Command parsing and validation
- User interaction and prompts
- Output formatting and colors

### 4.2 Integration Points

**Spotify Web API**:
- Authentication: OAuth2 flow
- Playlist operations: Create, read, update
- Search: Song/artist lookup
- Rate limits: 100 requests/minute

**Future: OpenRouter API**:
- AI conversation capabilities
- Music recommendation engine
- Natural language playlist building

## 5. Architecture Decision Records

### ADR-001: Ruby as Primary Language
**Decision**: Use Ruby 3.4.6 as the primary language
**Rationale**: 
- Current stable version with PRISM parser
- Rich ecosystem for CLI tools
- Easy gem distribution
- Future Rails integration compatibility

### ADR-002: thor for CLI Framework
**Decision**: Use thor for command-line interface
**Rationale**:
- Rails-like command structure
- Simple and well-maintained
- Good documentation and community
- Built-in help generation

### ADR-003: Modular Monolith Architecture
**Decision**: Single gem with modular components
**Rationale**:
- Simpler deployment and distribution
- Easier testing and maintenance
- Clear separation of concerns
- Future web app can use same gem

### ADR-004: YAML Configuration
**Decision**: Use YAML for configuration files
**Rationale**:
- Human-readable format
- Good Ruby support
- Easy to edit manually
- Supports complex nested structures

### ADR-005: OAuth2 for Spotify Authentication
**Decision**: Use OAuth2 flow for Spotify authentication
**Rationale**:
- Spotify's standard authentication method
- Secure token handling
- No need to store user passwords
- Industry standard

## 6. Implementation Guidance

### 6.1 Development Setup

```bash
# Install Ruby via mise
mise install ruby 3.4.6

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Build gem
gem build groove.gemspec
```

### 6.2 Project Structure

```
groove.rb/
├── lib/
│   ├── groove/
│   │   ├── cli.rb                 # Main CLI interface
│   │   ├── authentication.rb     # OAuth2 authentication
│   │   ├── file_parser.rb        # File parsing logic
│   │   ├── spotify_client.rb     # Spotify API client
│   │   ├── playlist_manager.rb   # Playlist operations
│   │   ├── configuration.rb      # Config management
│   │   └── version.rb            # Version constant
│   └── groove.rb                 # Main entry point
├── bin/
│   └── groove                    # CLI executable
├── spec/
│   ├── groove/
│   │   ├── cli_spec.rb
│   │   ├── authentication_spec.rb
│   │   ├── file_parser_spec.rb
│   │   ├── spotify_client_spec.rb
│   │   ├── playlist_manager_spec.rb
│   │   └── configuration_spec.rb
│   └── spec_helper.rb
├── docs/
│   ├── PRD.md
│   ├── epic-stories.md
│   └── tech-specs/
├── examples/
│   ├── songs.csv
│   ├── songs.txt
│   └── songs.json
├── gemspec
├── Gemfile
├── Rakefile
└── README.md
```

### 6.3 Key Implementation Patterns

**Error Handling**:
- Use custom exception classes for different error types
- Provide clear, actionable error messages
- Log errors with appropriate levels
- Exit with meaningful exit codes

**Configuration Management**:
- Use dry-configurable for type-safe configuration
- Support environment variable overrides
- Validate configuration on startup
- Provide sensible defaults

**API Integration**:
- Implement retry logic for transient failures
- Handle rate limiting gracefully
- Use connection pooling for efficiency
- Mock external APIs in tests

## 7. Proposed Source Tree

```
groove.rb/
├── lib/
│   ├── groove/
│   │   ├── cli.rb                 # Main CLI interface using thor
│   │   ├── authentication.rb     # OAuth2 authentication flow
│   │   ├── file_parser.rb        # Multi-format file parsing
│   │   ├── spotify_client.rb     # Spotify Web API client
│   │   ├── playlist_manager.rb   # Playlist CRUD operations
│   │   ├── configuration.rb      # YAML config management
│   │   ├── progress_bar.rb       # Progress indication wrapper
│   │   ├── errors.rb             # Custom exception classes
│   │   └── version.rb            # Version constant
│   └── groove.rb                 # Main entry point
├── bin/
│   └── groove                    # CLI executable
├── spec/
│   ├── groove/
│   │   ├── cli_spec.rb
│   │   ├── authentication_spec.rb
│   │   ├── file_parser_spec.rb
│   │   ├── spotify_client_spec.rb
│   │   ├── playlist_manager_spec.rb
│   │   ├── configuration_spec.rb
│   │   ├── progress_bar_spec.rb
│   │   └── errors_spec.rb
│   ├── fixtures/
│   │   ├── songs.csv
│   │   ├── songs.txt
│   │   ├── songs.json
│   │   └── config.yaml
│   └── spec_helper.rb
├── docs/
│   ├── PRD.md
│   ├── epic-stories.md
│   ├── solution-architecture.md
│   └── tech-specs/
│       ├── tech-spec-epic-1.md
│       └── tech-spec-epic-2.md
├── examples/
│   ├── songs.csv
│   ├── songs.txt
│   ├── songs.json
│   └── config.yaml
├── .github/
│   └── workflows/
│       └── ci.yml
├── gemspec
├── Gemfile
├── Gemfile.lock
├── Rakefile
├── .gitignore
├── .rubocop.yml
├── .rspec
└── README.md
```

## 8. Testing Strategy

### 8.1 Testing Approach

**Unit Tests**: Test individual components in isolation
**Integration Tests**: Test component interactions
**CLI Tests**: Test full command-line execution
**API Tests**: Mock external API calls

### 8.2 Test Structure

```ruby
# Example test structure
RSpec.describe Groove::SpotifyClient do
  describe '#search_song' do
    it 'finds exact matches' do
      # Test implementation
    end
    
    it 'handles fuzzy matches' do
      # Test implementation
    end
    
    it 'handles API errors gracefully' do
      # Test implementation
    end
  end
end
```

### 8.3 Test Coverage

- **Target**: 90%+ code coverage
- **Tools**: RSpec + SimpleCov
- **Mocking**: WebMock for HTTP requests
- **Fixtures**: Sample files for testing

## 9. Deployment and Operations

### 9.1 Distribution Strategy

**RubyGems**: Primary distribution method
**GitHub Releases**: Binary releases for non-Ruby users
**Homebrew**: macOS package manager support

### 9.2 Installation Methods

```bash
# Via RubyGems
gem install groove

# Via Bundler
gem 'groove', '~> 1.0'

# Via Homebrew (future)
brew install groove
```

### 9.3 Future Deployment

**Web Application**: Separate Rails app using this gem
**Deployment**: Kamal + Hetzner
**Infrastructure**: Containerized deployment

## 10. Security

### 10.1 Authentication Security

- OAuth2 tokens stored securely
- No password storage required
- Token refresh handling
- Secure credential management

### 10.2 Data Security

- Configuration files with appropriate permissions
- No sensitive data in logs
- Secure token storage
- Input validation and sanitization

---

## Specialist Sections

### Testing Specialist Section
*Testing strategy covers unit, integration, and CLI testing with 90%+ coverage target.*

### DevOps Specialist Section  
*Deployment strategy includes RubyGems distribution with future Kamal + Hetzner deployment for web app.*

### Security Specialist Section
*Security focuses on OAuth2 token management and secure credential storage.*

---

_Generated using BMad Method Solution Architecture workflow_
