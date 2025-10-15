# CI/Local Integration Setup Guide

This guide explains how to set up and verify consistent code quality checks between local development and CI environments.

## Overview

The project uses the following tools for code quality and testing:
- **RuboCop**: Ruby code style and quality analysis
- **Brakeman**: Security vulnerability scanning
- **RSpec**: Test suite execution
- **Overcommit**: Pre-commit hooks for local development

## Local Development Setup

### 1. Install Dependencies

```bash
# Install Ruby dependencies
bundle install

# Install pre-commit hooks
bundle exec overcommit --install

# Sign the overcommit configuration
bundle exec overcommit --sign
```

### 2. Running Checks Manually

```bash
# Run RuboCop with convention-level failures
bundle exec rubocop --fail-level convention

# Run Brakeman security scan
bundle exec brakeman --force --quiet

# Run RSpec test suite
bundle exec rspec

# Run all checks via Rake
bundle exec rake
```

### 3. Pre-commit Hooks

The following hooks are enabled and will run automatically on commit:

- **RuboCop**: Checks Ruby code style (convention level)
- **Brakeman**: Security vulnerability scanning
- **RSpec**: Test suite execution (enabled but can be disabled for performance)

To bypass hooks when needed:
```bash
git commit --no-verify -m "Emergency commit"
```

## CI Pipeline Configuration

### GitHub Actions Workflow

The CI pipeline (`.github/workflows/ci.yml`) runs on:
- Push to `main` and `develop` branches
- Pull requests to `main` branch
- Weekly scheduled runs

### Ruby Versions

The CI tests against multiple Ruby versions:
- Ruby 3.0
- Ruby 3.1  
- Ruby 3.2

### CI Steps

1. **Setup**: Checkout code and install Ruby dependencies
2. **RuboCop**: Run style checks with `--fail-level error`
3. **RSpec**: Execute test suite
4. **Brakeman**: Security scan with JSON output
5. **Artifacts**: Upload Brakeman reports and coverage data

## Configuration Synchronization

### RuboCop Configuration

- **File**: `.rubocop.yml`
- **Target Ruby Version**: 3.0 (compatible with CI matrix)
- **Fail Level**: Convention (local) / Error (CI)
- **Exclusions**: `vendor/**/*`, `spec/fixtures/**/*`

### Brakeman Configuration

- **File**: `.brakeman.ignore`
- **Output Formats**: JSON (CI), HTML (local)
- **Force Mode**: Enabled for consistent results

### Overcommit Configuration

- **File**: `.overcommit.yml`
- **RuboCop**: Enabled with convention fail-level
- **Brakeman**: Enabled with force and quiet flags
- **RSpec**: Enabled (can be disabled for performance)

## Performance Targets

| Tool | Local Target | CI Target | Actual Performance |
|------|-------------|-----------|-------------------|
| RuboCop | < 10s | < 10s | ~1.7s |
| Brakeman | < 15s | < 15s | ~0.6s |
| RSpec | < 30s | < 30s | ~0.4s |
| **Total** | < 30s | < 5min | ~2.7s |

## Troubleshooting

### Overcommit Signature Issues

If you see signature errors:
```bash
bundle exec overcommit --sign
```

### RuboCop Failures

To see detailed violations:
```bash
bundle exec rubocop --fail-level convention --format detailed
```

### Brakeman Warnings

To see security warnings:
```bash
bundle exec brakeman --force
```

### CI Failures

Check the GitHub Actions logs for specific failure details. Common issues:
- Ruby version compatibility
- Missing dependencies
- Configuration mismatches

## Verification Checklist

- [ ] Local RuboCop runs without errors
- [ ] Local Brakeman runs without warnings
- [ ] Local RSpec runs without failures
- [ ] Pre-commit hooks run on commit
- [ ] CI pipeline passes on clean commits
- [ ] CI pipeline fails on violations
- [ ] Performance targets are met
- [ ] Configuration files are synchronized

## Best Practices

1. **Always run checks locally** before pushing
2. **Fix violations immediately** rather than accumulating them
3. **Use `--no-verify` sparingly** and only for emergencies
4. **Keep configurations synchronized** between local and CI
5. **Monitor CI performance** and adjust targets as needed

## Related Files

- `.github/workflows/ci.yml` - CI pipeline configuration
- `.overcommit.yml` - Pre-commit hooks configuration
- `.rubocop.yml` - RuboCop style configuration
- `.brakeman.ignore` - Brakeman ignore patterns
- `Gemfile` - Ruby dependencies
- `Rakefile` - Rake task definitions
