# Epic 3: Code Quality & Testing Pipeline - Technical Architecture

## Architecture Overview
**Architecture Type**: Developer Experience Pipeline
**Pattern**: Quality Gate Architecture with Defense in Depth
**Scale**: Single-repository Ruby gem with automated quality gates

## Architectural Principles
- **Fast Feedback**: Sub-30 second local validation
- **Defense in Depth**: Multiple quality checkpoints
- **Developer Productivity**: Minimal friction workflows
- **Fail Fast**: Early error detection and prevention

## Component Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Local Dev     │    │   Git Hooks    │    │   CI/CD        │
│   Environment   │    │   (Overcommit)  │    │   (GitHub)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   RuboCop       │    │   Pre-commit    │    │   Automated     │
│   (Style)       │    │   Validation   │    │   Testing       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Brakeman      │    │   Test Suite   │    │   Security      │
│   (Security)   │    │   (RSpec)       │    │   Scanning      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Technical Components

### 1. RuboCop Integration
- **Configuration**: `.rubocop.yml` with custom rules
- **Integration**: Rake tasks and CI pipeline
- **Performance**: Parallel execution where possible
- **Customization**: Project-specific style guidelines

### 2. Overcommit Pre-commit Hooks
- **Configuration**: `.overcommit.yml` with hook definitions
- **Hooks**: RuboCop, RSpec, Brakeman
- **Performance**: Fast execution (< 10 seconds)
- **Bypass**: `--no-verify` option for emergencies

### 3. GitHub Actions CI Pipeline
- **Workflow**: `.github/workflows/ci.yml`
- **Triggers**: Push, PR, schedule
- **Matrix**: Multiple Ruby versions
- **Caching**: Gem and dependency caching
- **Notifications**: Status reporting

### 4. Brakeman Security Scanning
- **Configuration**: `.brakeman.ignore` for false positives
- **Integration**: Pre-commit and CI
- **Reporting**: JSON and HTML output
- **Thresholds**: Configurable security levels

### 5. Test Suite Optimization
- **Framework**: RSpec with parallel execution
- **Performance**: < 30 second execution time
- **Coverage**: Code coverage reporting
- **Integration**: CI pipeline integration

## Implementation Strategy

**Phase 1: Foundation** (Week 1)
- RuboCop setup and configuration
- Basic test suite optimization

**Phase 2: Automation** (Week 2)
- Overcommit pre-commit hooks
- GitHub Actions CI pipeline

**Phase 3: Security** (Week 3)
- Brakeman integration
- Security scanning automation

**Phase 4: Optimization** (Week 4)
- Performance tuning
- Documentation and training

## Technical Requirements

**Dependencies**:
- Ruby 3.0+
- Bundler 2.0+
- Git 2.0+
- GitHub Actions

**Configuration Files**:
- `.rubocop.yml` - RuboCop configuration
- `.overcommit.yml` - Pre-commit hooks
- `.github/workflows/ci.yml` - CI pipeline
- `.brakeman.ignore` - Security exceptions
- `Rakefile` - Task definitions

**Performance Targets**:
- Local validation: < 10 seconds
- CI pipeline: < 5 minutes
- Test suite: < 30 seconds
- Security scan: < 2 minutes

## Detailed Technical Specifications

### Story 1.1: RuboCop Integration - Tech Spec

**Technical Requirements**:
- **RuboCop Version**: 1.50+ (latest stable)
- **Configuration**: `.rubocop.yml` with project-specific rules
- **Integration**: Rake tasks and CI pipeline
- **Performance**: Parallel execution with `--parallel` flag

**Implementation Details**:

```yaml
# .rubocop.yml
AllCops:
  NewCops: enable
  TargetRubyVersion: 3.0
  Exclude:
    - 'vendor/**/*'
    - 'spec/fixtures/**/*'

Style/StringLiterals:
  EnforcedStyle: single_quotes

Layout/LineLength:
  Max: 120

Metrics/MethodLength:
  Max: 20

Metrics/ClassLength:
  Max: 150
```

**Rake Integration**:
```ruby
# Rakefile
require 'rubocop/rake_task'

RuboCop::RakeTask.new do |task|
  task.options = ['--parallel']
end

task default: [:rubocop, :spec]
```

### Story 1.2: Overcommit Pre-commit Hooks - Tech Spec

**Technical Requirements**:
- **Overcommit Version**: 0.60+ (latest stable)
- **Configuration**: `.overcommit.yml` with hook definitions
- **Performance**: < 10 second execution time
- **Bypass**: `--no-verify` option support

**Implementation Details**:

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

### Story 1.3: GitHub Actions CI Pipeline - Tech Spec

**Technical Requirements**:
- **Workflow**: `.github/workflows/ci.yml`
- **Triggers**: Push, PR, schedule
- **Matrix**: Multiple Ruby versions (3.0, 3.1, 3.2)
- **Caching**: Gem and dependency caching
- **Performance**: < 5 minute execution time

**Implementation Details**:

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

### Story 1.4: Brakeman Security Scanning - Tech Spec

**Technical Requirements**:
- **Brakeman Version**: 5.4+ (latest stable)
- **Configuration**: `.brakeman.ignore` for false positives
- **Integration**: Pre-commit and CI
- **Reporting**: JSON and HTML output
- **Performance**: < 2 minute execution time

**Implementation Details**:

```ruby
# Gemfile
group :development, :test do
  gem 'brakeman', require: false
end
```

**Rake Integration**:
```ruby
# Rakefile
require 'brakeman'

desc "Run Brakeman security scan"
task :brakeman do
  Brakeman.run(
    app_path: ".",
    print_report: true,
    output_files: ["brakeman-report.html", "brakeman-report.json"]
  )
end
```

### Story 1.5: Test Suite Optimization - Tech Spec

**Technical Requirements**:
- **Framework**: RSpec with parallel execution
- **Performance**: < 30 second execution time
- **Coverage**: Code coverage reporting
- **Integration**: CI pipeline integration

**Implementation Details**:

```ruby
# Gemfile
group :development, :test do
  gem 'rspec'
  gem 'rspec-parallel'
  gem 'simplecov'
  gem 'simplecov-lcov'
end
```

```ruby
# spec/spec_helper.rb
require 'simplecov'
require 'simplecov-lcov'

SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  minimum_coverage 80
end

RSpec.configure do |config|
  config.parallel_execution = true
  config.parallel_execution_workers = 4
end
```

**Rake Integration**:
```ruby
# Rakefile
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation --parallel'
end

task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task[:spec].invoke
end
```

## Implementation Roadmap

**Week 1**: RuboCop + Test Suite Optimization
**Week 2**: Overcommit + GitHub Actions
**Week 3**: Brakeman + Security Integration
**Week 4**: Performance Tuning + Documentation
