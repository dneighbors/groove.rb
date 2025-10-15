# Story 3.3: GitHub Actions CI Pipeline

## Story Definition
**Story ID**: STORY-3.3
**Epic**: Epic 3 - Code Quality & Testing Pipeline
**Status**: Ready for Development
**Priority**: HIGH
**Created**: 2024-01-15
**Owner**: Bob (Scrum Master)

## User Story
**As a** developer
**I want** automated testing on every push and PR
**So that** code quality is maintained in the main branch

## Acceptance Criteria
- [ ] GitHub Actions workflow file created (`.github/workflows/ci.yml`)
- [ ] Multi-Ruby version matrix working (3.0, 3.1, 3.2)
- [ ] RuboCop integration functional
- [ ] RSpec integration functional
- [ ] Brakeman integration functional
- [ ] Caching optimization working
- [ ] Status reporting functional
- [ ] Performance target: < 5 minute execution time

## Technical Requirements
- **Workflow**: `.github/workflows/ci.yml`
- **Triggers**: Push, PR, schedule
- **Matrix**: Multiple Ruby versions (3.0, 3.1, 3.2)
- **Caching**: Gem and dependency caching
- **Performance**: < 5 minute execution time

## Implementation Details

### GitHub Actions Workflow
```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # Weekly

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby-version: [3.0, 3.1, 3.2]

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: ${{ matrix.ruby-version }}
        bundler-cache: true

    - name: Run RuboCop
      run: bundle exec rubocop

    - name: Run RSpec
      run: bundle exec rspec

    - name: Run Brakeman
      run: bundle exec brakeman --quiet

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/lcov.info
```

## Definition of Done
- [ ] Workflow file created and functional
- [ ] All Ruby versions (3.0, 3.1, 3.2) tested
- [ ] RuboCop checks integrated and passing
- [ ] RSpec tests integrated and passing
- [ ] Brakeman security scan integrated
- [ ] Caching reduces build time
- [ ] Status badges working
- [ ] Performance meets < 5 minute target
- [ ] Documentation explains CI process

## Dependencies
- Story 3.1 (RuboCop Integration)
- Story 3.4 (Brakeman Security) - for Brakeman integration
- Story 3.5 (Test Suite Optimization) - for optimized tests
- GitHub repository with Actions enabled

## Testing
- Test workflow execution on push
- Test workflow execution on PR
- Verify multi-Ruby version matrix
- Test caching effectiveness
- Validate status reporting
- Test performance targets

## Notes
This story integrates all the quality tools into a single CI pipeline. It depends on RuboCop, Brakeman, and optimized test suite being available.
