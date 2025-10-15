# groove.rb Project Overview

**Project:** groove.rb - Spotify Playlist Sync Tool  
**Created:** 2025-10-15  
**Last Updated:** 2024-01-15  

## Project Description

A Ruby gem that syncs text lists of songs/artists to Spotify playlists, with future AI-powered music discovery capabilities.

**Core Features:**
- Sync text files (CSV, TXT, JSON) to Spotify playlists
- OAuth2 authentication with Spotify
- Command-line interface
- Future: AI conversation for music discovery

## Epic Status

### **Epic 1: Core Playlist Sync (MVP)**
- **Status**: In Development
- **Stories**: 6 stories (1.1-1.6)
- **Progress**: 3 stories completed
- **Workflow**: `docs/workflows/epic-1-2-workflow-status.md`

### **Epic 2: AI Music Discovery (Future)**
- **Status**: Future Planning
- **Stories**: 4 stories (2.1-2.4)
- **Progress**: Not started
- **Workflow**: `docs/workflows/epic-1-2-workflow-status.md`

### **Epic 3: Code Quality & Testing Pipeline**
- **Status**: Ready for Development
- **Stories**: 5 stories (3.1-3.5)
- **Progress**: All stories created
- **Workflow**: `docs/workflows/epic-3-workflow-status.md`

### **Epic 4: Deployment Pipeline (Future)**
- **Status**: Future Planning
- **Stories**: TBD
- **Progress**: Epic definition only
- **Workflow**: TBD

## Documentation Structure

```
docs/
├── epics/                    # Epic definitions
│   ├── epic-1-core-playlist-sync.md
│   ├── epic-2-ai-music-discovery.md
│   ├── epic-3-code-quality.md
│   └── epic-4-deployment.md
├── stories/                  # User stories
│   ├── story-1.*.md          # Epic 1 stories
│   └── story-3.*.md          # Epic 3 stories
├── tech-specs/              # Technical specifications
│   ├── tech-spec-epic-1.md
│   ├── tech-spec-epic-2.md
│   └── tech-spec-epic-3.md
├── bmm-workflow-status.md   # BMad workflow tracking (SINGLE FILE)
└── DOCUMENTATION-STRUCTURE.md
```

## Current Focus

**Active Epic**: Epic 3 - Code Quality & Testing Pipeline
**Next Action**: Begin development of Story 3.1 (RuboCop Integration)
**Command**: `@bmad/bmm/agents/dev develop`

## BMad Workflow Status

**Project**: Phase 4 - Implementation (All epics tracked in single workflow)
**Epic 1 & 2**: 3 stories completed
**Epic 3**: Ready to start
**Epic 4**: Future planning
**Workflow**: `docs/bmm-workflow-status.md` (SINGLE FILE)

---

**Project is well-organized and ready for continued development!** 🚀
