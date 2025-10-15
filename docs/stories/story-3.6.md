# Story 3.6: CI/Local Integration Verification

## Story Definition
**Story ID**: STORY-3.6
**Epic**: Epic 3 - Code Quality & Testing Pipeline
**Status**: Ready for Development
**Priority**: MEDIUM
**Created**: 2025-01-15
**Owner**: Bob (Scrum Master)

## User Story
**As a** developer
**I want** consistent code quality checks running both locally and in CI
**So that** I have confidence that the same standards are enforced everywhere

## Acceptance Criteria
- [ ] RuboCop runs identically in both local pre-commit hooks and CI
- [ ] Brakeman runs identically in both local pre-commit hooks and CI
- [ ] CI fails build on RuboCop violations
- [ ] CI fails build on Brakeman security warnings
- [ ] Local and CI configurations are synchronized
- [ ] Clear documentation on how to run checks locally
- [ ] Performance targets met for both local and CI execution
- [ ] Test suite runs consistently in both environments

## Technical Requirements
- **Consistency**: Identical configurations between local and CI
- **Performance**: Local checks < 30 seconds, CI < 5 minutes
- **Reliability**: Same results in both environments
- **Documentation**: Clear setup and usage instructions

## Implementation Details

### Configuration Synchronization
- Ensure `.rubocop.yml` is identical in both environments
- Ensure `.brakeman.ignore` is identical in both environments
- Ensure `.overcommit.yml` configuration matches CI expectations
- Verify Gemfile.lock consistency

### CI Pipeline Verification
```yaml
# .github/workflows/ci.yml verification
name: CI Pipeline
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ruby-version: [3.0, 3.1, 3.2]
    steps:
      - uses: actions/checkout@v4
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: ${{ matrix.ruby-version }}
          bundler-cache: true
      - name: Run RuboCop
        run: bundle exec rubocop --fail-level error
      - name: Run Brakeman
        run: bundle exec brakeman --force --quiet
      - name: Run RSpec
        run: bundle exec rake spec
```

### Local Development Setup
```bash
# Install dependencies
bundle install

# Install pre-commit hooks
bundle exec overcommit --install

# Run checks manually
bundle exec rubocop
bundle exec brakeman --force --quiet
bundle exec rake spec
```

### Performance Targets
- **Local pre-commit hooks**: < 30 seconds total
- **CI pipeline**: < 5 minutes total
- **RuboCop**: < 10 seconds
- **Brakeman**: < 15 seconds
- **RSpec**: < 30 seconds

## Definition of Done
- [ ] RuboCop configuration verified identical in both environments
- [ ] Brakeman configuration verified identical in both environments
- [ ] CI pipeline runs successfully on test commits
- [ ] Local pre-commit hooks run successfully
- [ ] Performance targets met in both environments
- [ ] Documentation updated with setup instructions
- [ ] Test commits with violations fail CI appropriately
- [ ] Test commits with violations fail local hooks appropriately

## Dependencies
- Completed Stories 3.1-3.5
- GitHub Actions workflow
- Overcommit configuration
- RuboCop configuration
- Brakeman configuration

## Testing
- Test CI pipeline with clean commits
- Test CI pipeline with RuboCop violations
- Test CI pipeline with Brakeman warnings
- Test local pre-commit hooks with violations
- Test local pre-commit hooks with clean commits
- Verify performance in both environments
- Test bypass functionality (--no-verify)

## Notes
This story ensures that developers get the same feedback locally as they do in CI, preventing the "works on my machine" problem and ensuring consistent code quality standards across the entire development workflow.

## Related Files
- `.github/workflows/ci.yml`
- `.overcommit.yml`
- `.rubocop.yml`
- `.brakeman.ignore`
- `Gemfile.lock`
- `Rakefile`
