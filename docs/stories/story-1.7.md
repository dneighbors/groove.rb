# Story 1.7: Playlist Discovery and Listing

**Epic:** Epic 1 - Core Playlist Sync (MVP)  
**Story ID:** 1.7  
**Status:** Ready  
**Story Points:** 5

## Story

**As a** user  
**I want** to see a list of my existing Spotify playlists with their IDs  
**So that** I can easily find playlist IDs to use with the `groove playlist add` command

## Context

Currently, users must obtain playlist IDs from the Spotify web interface or app, which is cumbersome. This story implements a `groove playlist list` command to display the user's playlists directly in the CLI, making it easy to discover playlist IDs for use with existing commands.

**User Pain Point Addressed:** When running `groove playlist add --file songs.txt --playlist-id <ID>`, users don't have an easy way to discover the playlist ID. They must navigate to Spotify's web interface, right-click a playlist, and copy the ID from the URL.

## Acceptance Criteria

1. **List Command Implementation**
   - [ ] `groove playlist list` command fetches and displays user's playlists
   - [ ] Command is properly integrated into the CLI subcommand structure
   - [ ] Help documentation includes the list command

2. **Playlist Information Display**
   - [ ] Shows playlist name
   - [ ] Shows playlist ID (for use with other commands)
   - [ ] Shows track count
   - [ ] Shows visibility (public/private)
   - [ ] Output is formatted as a readable table

3. **API Integration**
   - [ ] Uses Spotify API `GET /v1/me/playlists` endpoint
   - [ ] Handles pagination for users with many playlists (>50)
   - [ ] Automatically fetches all pages of playlists
   - [ ] Properly handles authentication (reuses existing auth system)

4. **Optional Features**
   - [ ] `--format json` flag for JSON output (useful for scripting)
   - [ ] `--filter <name>` option to search playlists by name (case-insensitive)
   - [ ] Shows owner information for collaborative playlists

5. **Error Handling**
   - [ ] Clear error message if not authenticated
   - [ ] Handles API rate limiting gracefully
   - [ ] Handles network errors appropriately
   - [ ] Displays helpful message if user has no playlists

## Tasks / Subtasks

### Task 1: Extend PlaylistManager with list functionality (AC: 2, 3)
- [ ] Add `list_playlists` method to `PlaylistManager`
- [ ] Implement Spotify API call to `GET /v1/me/playlists`
- [ ] Handle pagination (Spotify returns 50 playlists per page)
- [ ] Return structured data with name, ID, track count, visibility, owner
- [ ] Add error handling for API failures
- [ ] Test with mocked API responses

### Task 2: Implement CLI list command (AC: 1)
- [ ] Add `list` command to `Groove::Playlist` CLI class
- [ ] Add command-line options: `--format`, `--filter`
- [ ] Integrate with `PlaylistManager.list_playlists`
- [ ] Handle command-line argument parsing
- [ ] Update help text in `lib/groove/cli.rb`

### Task 3: Format and display output (AC: 2, 4)
- [ ] Implement table formatting for default output
- [ ] Include columns: Name, ID, Tracks, Visibility, Owner
- [ ] Implement JSON formatting for `--format json` option
- [ ] Implement name filtering for `--filter` option
- [ ] Add visual indicators (🔒 for private, 🌍 for public)
- [ ] Handle empty results gracefully

### Task 4: Error handling and edge cases (AC: 5)
- [ ] Check authentication before API call
- [ ] Handle "not authenticated" error with helpful message
- [ ] Handle rate limiting with retry logic
- [ ] Handle network timeouts and connection errors
- [ ] Display message for users with no playlists
- [ ] Test error scenarios

### Task 5: Testing (AC: All)
- [ ] Unit tests for `PlaylistManager.list_playlists`
- [ ] Mock Spotify API responses (success, pagination, errors)
- [ ] Test CLI command integration
- [ ] Test table formatting output
- [ ] Test JSON formatting output
- [ ] Test filtering functionality
- [ ] Test error handling paths
- [ ] Integration test with mocked auth

### Task 6: Documentation (AC: 1)
- [ ] Update `lib/groove/cli.rb` help text
- [ ] Add command to README examples
- [ ] Update usage documentation
- [ ] Document the `--format` and `--filter` options

## Dev Notes

### Architecture Patterns

**Spotify API Endpoint:**
```
GET https://api.spotify.com/v1/me/playlists
```

**Response Structure:**
```json
{
  "items": [
    {
      "id": "playlist_id",
      "name": "Playlist Name",
      "tracks": { "total": 42 },
      "public": true,
      "owner": { "display_name": "Username" }
    }
  ],
  "next": "https://api.spotify.com/v1/me/playlists?offset=50",
  "total": 150
}
```

**Pagination Handling:**
- Spotify returns max 50 playlists per page
- Use `next` field to fetch subsequent pages
- Continue until `next` is null

### Component Integration

**Files to Modify:**
- `lib/groove/playlist_manager.rb` - Add `list_playlists` method
- `lib/groove/playlist.rb` - Add `list` CLI command
- `lib/groove/cli.rb` - Update help documentation

**Existing Patterns to Follow:**
- Use `PlaylistManager` class for API interactions (consistent with Stories 1.4)
- Use Thor command structure in `Playlist` class (consistent with existing subcommands)
- Error handling with custom exceptions and user-friendly messages (consistent with Story 1.5)
- Colored output with visual indicators (consistent with Story 1.6)

### Testing Strategy

**Mock Data:**
- Create fixture for playlist list response
- Test with empty list (new user)
- Test with single page (<50 playlists)
- Test with multiple pages (pagination)

**Test Files:**
- `spec/groove/playlist_manager_spec.rb` - Add list_playlists tests
- `spec/groove/playlist_spec.rb` - Add CLI command tests (if separate file exists)

### Project Structure Notes

**Component Locations:**
- `lib/groove/playlist_manager.rb` - API interaction layer
- `lib/groove/playlist.rb` - CLI command layer
- `spec/groove/playlist_manager_spec.rb` - Unit tests

**Naming Conventions:**
- Method: `list_playlists` (snake_case, follows Ruby conventions)
- Command: `groove playlist list` (follows existing pattern)
- Options: `--format`, `--filter` (follows Thor conventions)

### References

**Source Documents:**
- [Tech Spec: Epic 1 - Story 1.7](docs/tech-specs/tech-spec-epic-1.md#story-17-playlist-discovery-and-listing)
- [Epic Definition](docs/epics/epic-1-core-playlist-sync.md)
- [Existing PlaylistManager](lib/groove/playlist_manager.rb) - For pattern consistency
- [Existing Playlist CLI](lib/groove/playlist.rb) - For command structure
- [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api/reference/get-a-list-of-current-users-playlists)

**Architecture Decisions:**
- Extend existing `PlaylistManager` rather than create new component
- Follow Thor CLI patterns established in Stories 1.1-1.6
- Reuse authentication system from Story 1.1
- Apply error handling patterns from Story 1.5

## Dev Agent Record

### Context Reference

<!-- Story context XML will be generated by story-context workflow -->

### Agent Model Used

<!-- To be filled during implementation -->

### Debug Log References

<!-- To be added during development if needed -->

### Completion Notes List

<!-- To be filled during implementation:
- Implementation approach taken
- Any deviations from the plan
- Issues encountered and solutions
- Additional features or improvements
-->

### File List

<!-- To be filled during implementation:
- Files created/modified
- Test files created/modified
-->

