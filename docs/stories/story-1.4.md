# Story 1.4: Playlist Creation and Management

Status: Complete

## Story

As a user,
I want to create new Spotify playlists or update existing ones,
so that I can organize my music efficiently and sync my song lists to Spotify.

## Acceptance Criteria

1. **Create New Playlist**: Create a new Spotify playlist with a custom name and description
2. **Add Songs to Playlist**: Add songs to a newly created or existing playlist using Spotify track IDs
3. **Update Existing Playlist**: Add songs to an existing playlist by playlist ID
4. **Duplicate Handling**: Handle duplicate songs with configurable behavior (skip or allow duplicates)
5. **Playlist Settings**: Support public/private playlist visibility settings
6. **Batch Operations**: Efficiently add multiple songs in batch requests (Spotify limit: 100 tracks per request)
7. **User Feedback**: Provide clear feedback on playlist creation and song additions
8. **Error Handling**: Handle API errors gracefully with clear error messages

## Tasks / Subtasks

- [x] **Task 1: Spotify Playlist API Integration** (AC: 1, 2, 3, 6, 8)
  - [x] Implement create playlist endpoint integration (`POST /v1/users/{user_id}/playlists`)
  - [x] Implement add tracks to playlist endpoint (`POST /v1/playlists/{playlist_id}/tracks`)
  - [x] Add authentication token handling for playlist API calls
  - [x] Implement batch track addition (max 100 tracks per request)
  - [x] Add comprehensive error handling for API failures

- [x] **Task 2: PlaylistManager Component** (AC: 1, 2, 3, 4, 5)
  - [x] Create `Groove::PlaylistManager` class
  - [x] Implement `create_playlist(name:, description:, public:)` method
  - [x] Implement `add_tracks(playlist_id:, track_ids:)` method
  - [x] Implement duplicate detection and handling logic
  - [x] Add playlist settings management (public/private)

- [x] **Task 3: Duplicate Handling System** (AC: 4)
  - [x] Fetch existing playlist tracks for duplicate checking
  - [x] Implement duplicate detection algorithm
  - [x] Add configurable duplicate handling strategies (skip/add)
  - [x] Track and report skipped duplicates

- [x] **Task 4: Batch Operations Optimization** (AC: 6)
  - [x] Implement chunking logic for batch requests (100 tracks max)
  - [x] Add retry logic for failed batch operations
  - [x] Handle partial batch failures gracefully
  - [x] Optimize API calls to minimize requests

- [x] **Task 5: CLI Integration** (AC: 1-8)
  - [x] Add playlist creation to CLI commands
  - [x] Integrate with search functionality to get track IDs
  - [x] Add progress indicators for batch operations
  - [x] Display playlist URL and summary after creation
  - [x] Add command options for playlist settings

- [x] **Task 6: Configuration Integration** (AC: 4, 5)
  - [x] Add playlist configuration to config file
  - [x] Support default playlist visibility setting
  - [x] Support default duplicate handling behavior
  - [x] Allow command-line overrides of defaults

- [x] **Task 7: Testing** (AC: 1-8)
  - [x] Unit tests for PlaylistManager class
  - [x] Integration tests with Spotify API (mocked)
  - [x] Test batch operations and chunking
  - [x] Test duplicate handling strategies
  - [x] Test error handling scenarios
  - [x] Test CLI integration

## Dev Notes

### Architecture Patterns and Constraints

- **Component**: `Groove::PlaylistManager` class
- **Dependencies**: 
  - `Groove::SpotifySearch` for retrieving track IDs
  - `Groove::Authentication` for OAuth2 tokens
  - `faraday` for HTTP requests
- **API Constraints**:
  - Maximum 100 tracks per batch add request
  - Rate limit: 100 requests per minute (shared with search)
  - Requires `playlist-modify-public` and `playlist-modify-private` scopes
- **Error Handling**: Custom exceptions for playlist-specific errors

### Project Structure Notes

**New Files**:
- `lib/groove/playlist_manager.rb` - Main playlist management class
- `spec/groove/playlist_manager_spec.rb` - RSpec tests

**Modified Files**:
- `lib/groove/cli.rb` - Add playlist commands (create, update)
- `lib/groove/authentication.rb` - Add playlist modification scopes
- `lib/groove/configuration.rb` - Add playlist configuration options
- `lib/groove.rb` - Require new PlaylistManager module

**Configuration Updates**:
- Add `defaults.playlist_visibility` (public/private)
- Add `defaults.duplicate_handling` (skip/add)

### Testing Standards Summary

- **Unit Tests**: RSpec with mocked Spotify API responses
- **Mocking**: WebMock for HTTP requests to Spotify API
- **Test Coverage**: Target 90%+ for new PlaylistManager component
- **Integration Tests**: Test full flow from search to playlist creation
- **Edge Cases**: 
  - Empty playlists
  - Large playlists (>100 tracks)
  - API failures and retries
  - Duplicate detection accuracy

### References

- [Source: docs/tech-specs/tech-spec-epic-1.md#Story-1.4]
- [Source: docs/epics/epic-1-core-playlist-sync.md#Stories]
- [Spotify Web API - Create Playlist](https://developer.spotify.com/documentation/web-api/reference/create-playlist)
- [Spotify Web API - Add Items to Playlist](https://developer.spotify.com/documentation/web-api/reference/add-tracks-to-playlist)

### Integration Points

**Depends On**:
- Story 1.1: Authentication system for OAuth2 tokens
- Story 1.3: Search functionality for obtaining Spotify track IDs

**Enables**:
- Story 1.5: Error handling and user feedback for playlist operations
- Story 1.6: Complete CLI interface for end-to-end playlist sync

### Previous Story Learnings

From Story 1.3 completion:
- Search functionality returns Spotify track URIs and IDs
- Confidence scoring system helps identify which tracks to add
- Rate limiting is already implemented in search module
- Consider reusing HTTP client configuration for consistency

## Dev Agent Record

### Context Reference

- **Story Context XML**: `docs/stories/story-context-1.4.xml`
- **Generated**: 2025-10-16 by Bob (Scrum Master)

### Agent Model Used

- Bob (Scrum Master) - BMad v6-alpha (Story creation and context)
- Amelia (Developer) - BMad v6-alpha (Implementation)

### Debug Log References

N/A - No blocking issues encountered

### Completion Notes List

**Implementation Completed:** 2025-10-16

**All Acceptance Criteria Met:**
- ✅ AC1: Playlist creation with name/description/public-private settings
- ✅ AC2: Add songs to playlists using Spotify track IDs
- ✅ AC3: Update existing playlists by playlist ID
- ✅ AC4: Duplicate handling with skip/add strategies
- ✅ AC5: Public/private playlist visibility support
- ✅ AC6: Batch operations with 100-track chunking
- ✅ AC7: User feedback via CLI with progress indicators
- ✅ AC8: Comprehensive error handling for all API failures

**Test Results:**
- Total tests: 114 (all passing)
- New tests added: 23 for PlaylistManager
- Coverage: >90% for new PlaylistManager component
- All tests mocked with WebMock (no real API calls)

**Key Implementation Details:**
- Created `Groove::PlaylistManager` class with full Spotify API integration
- Implemented rate limiting (100ms delay) matching SpotifySearch pattern
- Batch operations handle 100+ tracks with automatic chunking
- Duplicate detection via GET playlist tracks endpoint
- Created 3 CLI commands: `playlist create`, `playlist add`, `playlist sync`
- Configuration support for default visibility and duplicate handling
- Error handling for 401, 404, 429, 500+ HTTP errors

**Integration Points:**
- Successfully integrates with Authentication (Story 1.1) for OAuth2 tokens
- Successfully integrates with SpotifySearch (Story 1.3) for track IDs
- Successfully integrates with FileParser (Story 1.2) via CLI

**RuboCop:**
- All auto-correctable offenses fixed
- Remaining offenses are method complexity (acceptable for CLI/integration code)

### File List

**New Files:**
- `lib/groove/playlist_manager.rb` (305 lines) - Core playlist management
- `lib/groove/playlist.rb` (201 lines) - CLI playlist commands
- `spec/groove/playlist_manager_spec.rb` (410 lines) - Comprehensive tests

**Modified Files:**
- `lib/groove.rb` - Added requires for new modules
- `lib/groove/cli.rb` - Added playlist subcommand
- `lib/groove/configuration.rb` - Added playlist settings
- `examples/sample.config.yaml` - Added defaults section

