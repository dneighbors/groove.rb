# groove.rb 🎵

A Ruby gem that syncs text lists of songs and artists to Spotify playlists, with future AI-powered music discovery capabilities.

[![Ruby Version](https://img.shields.io/badge/ruby-%3E%3D%203.0.0-brightgreen)](https://ruby-lang.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![BMAD Method](https://img.shields.io/badge/BMAD-v6--alpha-blue)](https://github.com/bmad-code-org/BMAD-METHOD)

## 🚀 Quick Start

### Installation

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

### Setup

#### 1. Spotify App Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Note your Client ID and Client Secret
4. Add `http://localhost:8080/callback` to your app's redirect URIs

#### 2. Configuration

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

#### 3. Authentication

```bash
# Authenticate with Spotify
groove auth login

# Check authentication status
groove auth status

# Logout
groove auth logout
```

## 📖 Usage

```bash
# Show version
groove version

# Show help
groove help

# Sync songs from a text file
groove sync songs.txt --playlist "My Awesome Playlist"

# Sync songs from CSV
groove sync songs.csv --playlist "My Awesome Playlist" --format csv

# Sync songs from JSON
groove sync songs.json --playlist "My Awesome Playlist" --format json
```

## 🏗️ Project Architecture

This project uses the **BMAD Method** (Breakthrough Method of Agile AI-Driven Development) for development workflow and AI agent collaboration.

### Project Structure

```
groove.rb/
├── lib/groove/              # Core Ruby gem code
├── spec/                    # RSpec test suite
├── docs/                    # Project documentation
│   ├── epics/              # Epic definitions
│   ├── stories/            # User stories
│   ├── tech-specs/         # Technical specifications
│   └── bmm-workflow-status.md  # BMAD workflow tracking
├── BMAD-METHOD/            # BMAD framework (git submodule)
├── bmad/                   # Installed BMAD modules
└── update-bmad.sh          # BMAD update script
```

### Epic Status

| Epic | Status | Description |
|------|--------|-------------|
| **Epic 1** | 🚧 In Development | Core Playlist Sync (MVP) |
| **Epic 2** | 📋 Future Planning | AI Music Discovery |
| **Epic 3** | ✅ Ready for Development | Code Quality & Testing Pipeline |
| **Epic 4** | 📋 Future Planning | Deployment Pipeline |

**Current Focus**: Epic 3 - Code Quality & Testing Pipeline (RuboCop, Overcommit, GitHub Actions, Brakeman, Test Suite Optimization)

## 🤖 BMAD Method Integration

This project uses the **BMAD Method v6-alpha** for AI-driven development workflow.

### What is BMAD?

BMAD (Breakthrough Method of Agile AI-Driven Development) is a framework that provides:
- **Specialized AI Agents** (Analyst, PM, Architect, Developer, Scrum Master)
- **Structured Workflows** (Analysis → Planning → Solutioning → Implementation)
- **Context-Engineered Development** (Detailed stories with full context)

### BMAD Agents Available

- **@bmad/bmm/agents/analyst** - Requirements analysis and research
- **@bmad/bmm/agents/pm** - Product management and planning
- **@bmad/bmm/agents/architect** - Technical architecture and design
- **@bmad/bmm/agents/dev** - Development and implementation
- **@bmad/bmm/agents/sm** - Scrum Master and story management

### Using BMAD Agents in Cursor

Activate agents in Cursor chat:

```bash
# Activate specific agent
@bmad/bmm/agents/dev develop

# Activate team
@bmad/bmm/teams/team-all

# Party mode (all agents)
@bmad/core/agents/bmad-master *party-mode
```

## 🔄 Keeping BMAD Up to Date

BMAD is managed as a git submodule and can be easily updated:

### Automatic Updates

```bash
# Update BMAD to latest version
./update-bmad.sh
```

This script will:
1. Pull the latest BMAD source from the git submodule
2. Copy updated modules to the `bmad/` directory
3. Show version information
4. Complete the update

### Manual Updates

```bash
# Update git submodule
git submodule update --remote BMAD-METHOD

# Copy updated modules
cp -r BMAD-METHOD/src/modules/bmm/* bmad/bmm/
cp -r BMAD-METHOD/src/modules/bmb/* bmad/bmb/
cp -r BMAD-METHOD/src/modules/cis/* bmad/cis/
```

### BMAD Version Management

- **BMAD-METHOD/** - Source code (git submodule, v6-alpha branch)
- **bmad/** - Installed modules (auto-generated from source)
- **bmad/config.json** - Configuration file

### Benefits of This Approach

✅ **Easy Updates** - One command to update everything  
✅ **Version Control** - Track BMAD versions in git  
✅ **Clean Separation** - Source vs installed files  
✅ **No Duplication** - Single source of truth  
✅ **Maintainable** - Clear file organization  

## 🧪 Development

### Prerequisites

- Ruby 3.0+
- Bundler 2.0+
- Git 2.0+

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/dneighbors/groove.rb.git
cd groove.rb

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Start interactive console
bundle exec bin/console
```

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/groove/authentication_spec.rb

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Code Quality

This project uses several tools for code quality:

- **RuboCop** - Ruby style guide enforcement
- **Overcommit** - Pre-commit hooks
- **GitHub Actions** - CI/CD pipeline
- **Brakeman** - Security scanning
- **RSpec** - Testing framework

## 📚 Documentation

- **[Project Overview](docs/PROJECT-OVERVIEW.md)** - Complete project status
- **[Documentation Structure](docs/DOCUMENTATION-STRUCTURE.md)** - File organization guide
- **[BMAD Setup Guide](BMAD-SETUP-GUIDE.md)** - BMAD installation and management
- **[Epic Definitions](docs/epics/)** - Project epics and features
- **[User Stories](docs/stories/)** - Detailed development stories
- **[Technical Specs](docs/tech-specs/)** - Technical architecture and implementation

## 🤝 Contributing

We welcome contributions! This project uses BMAD Method for development workflow.

### Development Workflow

1. **Epic Planning** - Use BMAD PM agent for epic planning
2. **Story Creation** - Use BMAD SM agent for story creation
3. **Development** - Use BMAD Dev agent for implementation
4. **Code Quality** - Follow RuboCop and testing standards

### Getting Started

1. Fork the repository
2. Create a feature branch
3. Use BMAD agents for development workflow
4. Ensure all tests pass
5. Submit a pull request

### BMAD Agent Usage

```bash
# Start with PM agent for planning
@bmad/bmm/agents/pm plan

# Use SM agent for story creation
@bmad/bmm/agents/sm create-story

# Use Dev agent for implementation
@bmad/bmm/agents/dev develop
```

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🙏 Acknowledgments

- **BMAD Method** - AI-driven development framework
- **Spotify Web API** - Music streaming and playlist management
- **Ruby Community** - Excellent ecosystem and tools

---

**Built with ❤️ using BMAD Method v6-alpha**