# Story 3.2: Overcommit Pre-commit Hooks

## Story Definition
**Story ID**: STORY-3.2
**Epic**: Epic 3 - Code Quality & Testing Pipeline
**Status**: Ready for Development
**Priority**: HIGH
**Created**: 2024-01-15
**Owner**: Bob (Scrum Master)

## User Story
**As a** developer
**I want** pre-commit hooks that run RuboCop and tests
**So that** I catch issues before they reach the repository

## Acceptance Criteria
- [ ] Overcommit gem installed and configured
- [ ] `.overcommit.yml` configuration file created
- [ ] Pre-commit hooks installed successfully
- [ ] RuboCop hook runs on staged Ruby files
- [ ] RSpec hook runs on test files
- [ ] Brakeman hook runs security scan
- [ ] Hooks can be bypassed with `--no-verify` when needed
- [ ] Clear error messages for failed checks
- [ ] Performance target: < 10 seconds execution time

## Technical Requirements
- **Overcommit Version**: 0.60+ (latest stable)
- **Configuration**: `.overcommit.yml` with hook definitions
- **Performance**: < 10 second execution time
- **Bypass**: `--no-verify` option support

## Implementation Details

### Gemfile Addition
```ruby
group :development do
  gem 'overcommit'
end
```

### Overcommit Configuration
```yaml
# .overcommit.yml
PreCommit:
  RuboCop:
    enabled: true
    description: 'Run RuboCop on staged files'
    command: 'bundle exec rubocop'
    include: '**/*.rb'
    exclude: 'vendor/**/*'

  RSpec:
    enabled: true
    description: 'Run RSpec test suite'
    command: 'bundle exec rspec'
    files: 'spec/**/*_spec.rb'

  Brakeman:
    enabled: true
    description: 'Run Brakeman security scan'
    command: 'bundle exec brakeman --quiet'
```

### Installation Process
```bash
# Install overcommit
gem install overcommit

# Install hooks
overcommit --install

# Verify installation
overcommit --run
```

## Definition of Done
- [ ] Overcommit hooks installed and functional
- [ ] All three hooks (RuboCop, RSpec, Brakeman) working
- [ ] Configuration file follows project standards
- [ ] Bypass option functional for emergencies
- [ ] Error messages are clear and actionable
- [ ] Performance meets < 10 second target
- [ ] Documentation explains hook usage

## Dependencies
- Story 3.1 (RuboCop Integration) - must be completed first
- Story 3.4 (Brakeman Security) - for Brakeman hook
- Existing RSpec test suite

## Testing
- Test pre-commit hook execution
- Verify bypass functionality
- Test error handling and messages
- Validate performance targets
- Test hook installation process

## Notes
This story depends on RuboCop being installed (Story 3.1). The Brakeman hook can be added later when Story 3.4 is complete.
