# Epic 1: Core Playlist Sync - Technical Specification

**Epic ID**: 1
**Epic Title**: Core Playlist Sync (MVP)
**Stories**: 7 stories
**Author**: Developer
**Date**: 2025-10-15

## Epic Overview

This epic implements the core functionality for syncing text files of songs/artists to Spotify playlists. It includes authentication, file parsing, song matching, playlist management, error handling, and CLI interface.

## Stories

### Story 1.1: Spotify API Authentication
**As a** user  
**I want** to authenticate with my Spotify account  
**So that** I can create and modify playlists  

**Technical Implementation**:
- OAuth2 flow implementation using `oauth2` gem
- Secure token storage in `~/.config/groove/tokens.json`
- Token refresh handling for expired tokens
- Clear authentication error messages

**Components**: `Groove::Authentication`
**Dependencies**: `oauth2` gem, `faraday` for HTTP requests

### Story 1.2: Text File Parsing
**As a** user  
**I want** to upload text files with song/artist information  
**So that** I can create playlists from existing lists  

**Technical Implementation**:
- Support CSV format (artist,song)
- Support plain text format (artist - song)
- Support JSON format with structured data
- Handle file encoding issues (UTF-8)
- Validate file format and content

**Components**: `Groove::FileParser`
**Dependencies**: Built-in `csv`, `json`, `psych` gems

### Story 1.3: Spotify Song Search and Matching
**As a** user  
**I want** the system to find songs on Spotify based on artist/song names  
**So that** I don't have to manually search for each song  

**Technical Implementation**:
- Search Spotify API for songs using artist + track name
- Handle fuzzy matching for slight name variations
- Handle multiple artists (featuring, etc.)
- Return confidence scores for matches
- Handle songs not found on Spotify

**Components**: `Groove::SpotifyClient`
**Dependencies**: Spotify Web API, `faraday` for HTTP requests

### Story 1.4: Playlist Creation and Management
**As a** user  
**I want** to create new Spotify playlists or update existing ones  
**So that** I can organize my music efficiently  

**Technical Implementation**:
- Create new playlists with custom names
- Add songs to existing playlists
- Handle duplicate songs (skip or add option)
- Support public/private playlist settings
- Add playlist descriptions

**Components**: `Groove::PlaylistManager`
**Dependencies**: Spotify Web API, `Groove::SpotifyClient`

### Story 1.5: Error Handling and User Feedback
**As a** user  
**I want** clear feedback about what happened during sync  
**So that** I know which songs were added and which failed  

**Technical Implementation**:
- Report successful song additions
- Report songs not found on Spotify
- Handle API rate limits gracefully
- Provide retry mechanisms
- Clear error messages for common issues

**Components**: `Groove::Errors`, `Groove::ProgressBar`
**Dependencies**: `tty-progressbar`, `tty-color`

### Story 1.6: Command-Line Interface
**As a** user  
**I want** a simple command-line interface  
**So that** I can easily sync playlists from text files  

**Technical Implementation**:
- `groove sync <file> --playlist <name>` command
- `groove update <file> --playlist <id>` command
- Help documentation
- Configuration file support
- Verbose/quiet output options

**Components**: `Groove::CLI`
**Dependencies**: `thor` gem

### Story 1.7: Playlist Discovery and Listing
**As a** user  
**I want** to see a list of my existing Spotify playlists with their IDs  
**So that** I can easily find playlist IDs to use with the `add` command  

**Technical Implementation**:
- `groove playlist list` command to display user's playlists
- Fetch playlists from Spotify API (`GET /v1/me/playlists`)
- Display playlist name, ID, track count, and visibility (public/private)
- Support pagination for users with many playlists
- Optional filtering by playlist name (search/filter)
- Format output as table or JSON for scripting

**Components**: `Groove::PlaylistManager` (extend), `Groove::CLI`
**Dependencies**: Spotify Web API, existing authentication

## Architecture Extract

### Technology Stack
- **Ruby**: 3.4.6
- **CLI Framework**: thor 1.3.0
- **HTTP Client**: faraday 2.9.0
- **OAuth2**: oauth2 2.0.9
- **Progress**: tty-progressbar 0.18.2
- **Colors**: tty-color 0.6.0

### Component Structure
```
Groove::CLI (thor commands)
├── Groove::Authentication (OAuth2)
├── Groove::FileParser (CSV/Text/JSON)
├── Groove::SpotifyClient (API client)
├── Groove::PlaylistManager (CRUD)
├── Groove::Configuration (YAML)
└── Groove::ProgressBar (UI)
```

### Data Flow
1. Parse input file → Extract song/artist pairs
2. Authenticate with Spotify → Get access token
3. Search each song → Get Spotify track IDs
4. Create/update playlist → Add matched songs
5. Report results → Show success/failure counts

## Implementation Notes

### File Structure
```
lib/groove/
├── cli.rb                 # Main CLI interface
├── authentication.rb     # OAuth2 flow
├── file_parser.rb        # File parsing
├── spotify_client.rb     # API client
├── playlist_manager.rb   # Playlist operations
├── configuration.rb      # Config management
├── progress_bar.rb       # Progress indication
└── errors.rb             # Custom exceptions
```

### Configuration
```yaml
spotify:
  client_id: "your_client_id"
  client_secret: "your_client_secret"
  redirect_uri: "http://localhost:8080/callback"

defaults:
  playlist_visibility: "private"
  duplicate_handling: "skip"
  output_format: "text"
```

### Error Handling
- Custom exception classes for different error types
- Clear, actionable error messages
- Appropriate exit codes (0 = success, 1 = error)
- Logging with configurable levels

## Testing Approach

### Unit Tests
- Test each component in isolation
- Mock external API calls
- Test error conditions
- Test file parsing edge cases

### Integration Tests
- Test component interactions
- Test full CLI execution
- Test with real Spotify API (sandbox)

### Test Coverage
- Target: 90%+ code coverage
- Tools: RSpec + SimpleCov
- Mocking: WebMock for HTTP requests

## Dependencies

### Runtime Dependencies
- `thor` (1.3.0) - CLI framework
- `faraday` (2.9.0) - HTTP client
- `oauth2` (2.0.9) - OAuth2 authentication
- `tty-progressbar` (0.18.2) - Progress bars
- `tty-color` (0.6.0) - Color output
- `dry-configurable` (1.0.1) - Configuration

### Development Dependencies
- `rspec` (3.12.0) - Testing framework
- `simplecov` (0.22.0) - Code coverage
- `webmock` (3.19.1) - HTTP mocking
- `rubocop` (1.50.0) - Code linting

## Success Criteria

- [ ] User can authenticate with Spotify
- [ ] User can parse CSV, text, and JSON files
- [ ] User can search and match songs on Spotify
- [ ] User can create and update playlists
- [ ] User receives clear feedback on operations
- [ ] User can use CLI commands effectively
- [ ] All tests pass with 90%+ coverage
- [ ] Error handling works for all failure modes
