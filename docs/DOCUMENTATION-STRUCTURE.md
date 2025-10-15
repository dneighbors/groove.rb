# BMad Documentation Structure Guide

## 📁 Directory Structure

```
docs/
├── epics/                    # Epic definitions
│   ├── epic-1-core-playlist-sync.md
│   ├── epic-2-ai-music-discovery.md
│   ├── epic-3-code-quality.md
│   └── epic-4-deployment.md
├── stories/                  # User stories
│   ├── story-1.1.md         # Epic 1 stories
│   ├── story-1.2.md         # Epic 1 stories
│   ├── story-1.3.md         # Epic 1 stories
│   ├── story-3.1.md         # Epic 3 stories
│   ├── story-3.2.md         # Epic 3 stories
│   ├── story-3.3.md         # Epic 3 stories
│   ├── story-3.4.md         # Epic 3 stories
│   └── story-3.5.md         # Epic 3 stories
├── tech-specs/              # Technical specifications
│   ├── tech-spec-epic-1.md
│   ├── tech-spec-epic-2.md
│   └── tech-spec-epic-3.md
├── bmm-workflow-status.md   # BMad workflow tracking (SINGLE FILE)
├── PROJECT-OVERVIEW.md      # Project summary
└── DOCUMENTATION-STRUCTURE.md
```

## 📋 Naming Conventions

### Epics
- **Format**: `epic-{number}-{name}.md`
- **Examples**: 
  - `epic-1-core-features.md`
  - `epic-3-code-quality.md`
  - `epic-4-deployment.md`

### Stories
- **Format**: `story-{epic}.{story}.md`
- **Examples**:
  - `story-1.1.md` (Epic 1, Story 1)
  - `story-3.1.md` (Epic 3, Story 1)
  - `story-3.2.md` (Epic 3, Story 2)

### Tech Specs
- **Format**: `tech-spec-epic-{number}.md`
- **Examples**:
  - `tech-spec-epic-1.md`
  - `tech-spec-epic-3.md`
  - `tech-spec-epic-3-detailed.md` (for detailed specs)

## 🎯 Epic Numbering

**Epic 1**: Core Playlist Sync (MVP)
**Epic 2**: AI Music Discovery (Future)
**Epic 3**: Code Quality & Testing Pipeline
**Epic 4**: Deployment Pipeline (Future)

## 📊 Current Status

✅ **Epic 1**: Core Playlist Sync (MVP)
- Epic definition: `docs/epics/epic-1-core-playlist-sync.md`
- Stories: `docs/stories/story-1.*.md`
- Status: In Development

✅ **Epic 2**: AI Music Discovery (Future)
- Epic definition: `docs/epics/epic-2-ai-music-discovery.md`
- Stories: Future planning
- Status: Future Planning

✅ **Epic 3**: Code Quality & Testing Pipeline
- Epic definition: `docs/epics/epic-3-code-quality.md`
- Tech spec: `docs/tech-specs/tech-spec-epic-3.md`
- Stories: `docs/stories/story-3.*.md`
- Status: Ready for Development

✅ **Epic 4**: Deployment Pipeline (Future)
- Epic definition: `docs/epics/epic-4-deployment.md`
- Stories: Future planning
- Status: Future Planning

**Workflow Tracking**: `docs/bmm-workflow-status.md` (SINGLE FILE for entire project)

## 🚀 Next Steps

1. **Begin Epic 3 Development**: Start with Story 3.1 (RuboCop Integration)
2. **Follow naming conventions** for all future epics/stories
3. **Maintain consistent structure** across all documentation
4. **Update workflow status** as development progresses
