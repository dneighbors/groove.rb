# Epic 2: AI Music Discovery - Technical Specification

**Epic ID**: 2
**Epic Title**: AI Music Discovery (Future)
**Stories**: 4 stories (estimated)
**Author**: Developer
**Date**: 2025-10-15

## Epic Overview

This epic adds AI conversation capabilities for playlist building and music discovery. It integrates RubyLLM with OpenRouter to provide natural language interaction for creating and modifying playlists.

## Stories

### Story 2.1: AI Conversation Interface
**As a** user  
**I want** to chat with AI about music preferences  
**So that** I can discover new music through conversation  

**Technical Implementation**:
- Natural language conversation about music
- Integration with ruby_llm gem
- Music preference learning and storage
- Conversation history management
- Context-aware responses

**Components**: `Groove::AIConversation`
**Dependencies**: `ruby_llm` gem, OpenRouter API

### Story 2.2: Music Recommendation Engine
**As a** user  
**I want** AI to suggest songs based on our conversation  
**So that** I can discover music I might like  

**Technical Implementation**:
- AI-generated song recommendations
- Integration with Spotify's recommendation API
- Preference-based filtering
- Recommendation explanations
- Learning from user feedback

**Components**: `Groove::RecommendationEngine`
**Dependencies**: `ruby_llm`, Spotify Web API

### Story 2.3: Playlist Modification Through AI
**As a** user  
**I want** to modify playlists through AI conversation  
**So that** I can refine playlists naturally  

**Technical Implementation**:
- "Add more upbeat songs" type commands
- "Remove slow songs" type commands
- "Make this playlist longer" type commands
- AI understanding of music characteristics
- Natural language to playlist operations

**Components**: `Groove::AIPlaylistModifier`
**Dependencies**: `ruby_llm`, `Groove::PlaylistManager`

### Story 2.4: Web Interface for AI Chat
**As a** user  
**I want** a web interface for AI music conversation  
**So that** I can use the tool without command-line knowledge  

**Technical Implementation**:
- Web-based chat interface
- Ruby on Rails implementation
- User authentication
- Playlist management through web UI
- Real-time chat experience

**Components**: Separate Rails application
**Dependencies**: Rails, this groove gem, WebSocket for real-time chat

## Architecture Extract

### Technology Stack
- **AI Integration**: ruby_llm (latest)
- **API Provider**: OpenRouter
- **Web Framework**: Ruby on Rails (future)
- **Deployment**: Kamal + Hetzner (future)
- **Real-time**: ActionCable (future)

### Component Structure
```
Groove::AIConversation (ruby_llm integration)
├── Groove::RecommendationEngine (AI + Spotify)
├── Groove::AIPlaylistModifier (Natural language → operations)
└── Groove::PreferenceLearner (User preference storage)
```

### Data Flow
1. User chats with AI → Natural language input
2. AI processes conversation → Extract music preferences
3. AI generates recommendations → Use Spotify API
4. User approves/rejects → Learn preferences
5. AI modifies playlists → Natural language commands

## Implementation Notes

### AI Integration
```ruby
# Example AI conversation
class Groove::AIConversation
  def initialize
    @chat = RubyLLM.chat
    @chat.model = "claude-3-5-sonnet" # via OpenRouter
  end
  
  def chat_about_music(message)
    @chat.ask "Help user with music: #{message}"
  end
end
```

### Configuration
```yaml
ai:
  provider: "openrouter"
  model: "claude-3-5-sonnet"
  api_key: "your_openrouter_key"
  
preferences:
  storage_file: "~/.config/groove/preferences.json"
  learning_rate: 0.1
```

### Future Web Interface
- Separate Rails application
- Uses this groove gem as dependency
- WebSocket for real-time chat
- User authentication and sessions

## Testing Approach

### Unit Tests
- Test AI conversation logic
- Test recommendation generation
- Test preference learning
- Mock AI responses

### Integration Tests
- Test AI + Spotify integration
- Test conversation flow
- Test playlist modification

### AI Testing
- Test with various conversation patterns
- Test recommendation quality
- Test preference learning accuracy

## Dependencies

### Runtime Dependencies
- `ruby_llm` (latest) - AI integration
- `faraday` (2.9.0) - HTTP client for OpenRouter
- `json` (built-in) - Preference storage

### Future Dependencies
- `rails` (7.0+) - Web interface
- `actioncable` - Real-time chat
- `devise` - User authentication

## Success Criteria

- [ ] User can have natural conversations about music
- [ ] AI provides relevant music recommendations
- [ ] AI can modify playlists through conversation
- [ ] User preferences are learned and stored
- [ ] Conversation history is maintained
- [ ] Integration with existing playlist sync works
- [ ] Future web interface is planned

## Future Considerations

### Web Application Architecture
- Separate Rails repository
- Uses groove gem as dependency
- Real-time chat interface
- User authentication and profiles
- Playlist sharing and collaboration

### Deployment Strategy
- Kamal for containerized deployment
- Hetzner for hosting
- Separate infrastructure for web app
- Gem distribution via RubyGems

### Scalability
- AI conversation caching
- Recommendation pre-computation
- User preference clustering
- API rate limiting and optimization
