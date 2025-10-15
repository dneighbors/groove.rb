# RuboCop Integration Guide

## Overview

RuboCop is integrated into the groove.rb project to enforce Ruby code style and quality standards.

## Configuration

- **Configuration File**: `.rubocop.yml`
- **Target Ruby Version**: 3.0
- **Line Length**: 120 characters
- **Method Length**: 20 lines max
- **Class Length**: 150 lines max
- **String Style**: Single quotes preferred

## Usage

### Run RuboCop
```bash
bundle exec rake rubocop
```

### Run Default Task (RuboCop + Specs)
```bash
bundle exec rake
```

### Auto-correct Issues
```bash
bundle exec rubocop --auto-correct
```

## Integration Points

1. **Rake Tasks**: RuboCop runs as part of the default Rake task
2. **CI Pipeline**: Will be integrated in Story 3.3 (GitHub Actions)
3. **Pre-commit Hooks**: Will be integrated in Story 3.2 (Overcommit)

## Current Status

- ✅ RuboCop gem installed (v1.81.1)
- ✅ Configuration file created
- ✅ Rake task integration working
- ✅ Auto-corrected 654 style issues
- ⏳ CI pipeline integration (pending)
- ⏳ Pre-commit hooks integration (pending)

## Remaining Issues

169 offenses remain, mostly:
- RSpec-specific style issues (multiple expectations, example length)
- Complexity metrics requiring manual refactoring
- Gemspec configuration issues

These can be addressed incrementally as part of ongoing development.
