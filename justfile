set shell := ["bash", "-c"]

version := `gawk -F'"' '/VERSION/ { printf "%s", $2 }' lib/laser_cutter/version.rb`
rbenv   := 'eval "$(rbenv init - bash 2>/dev/null || true)"; bundle exec '
repo    := 'git@github.com:kigster/laser-cutter.git'

gem_name := 'laser-cutter'
gem_file := 'pkg/' + gem_name + '-' + version + '.gem'
gem_url  := 'https://rubygems.org/gems/' + gem_name

[no-exit-message]
recipes:
    just --choose

# Lint Ruby
lint:
    {{ rbenv }} rubocop

# Autocorrect Ruby (pass -A for unsafe corrections) and format Markdown
format *args: format-markdown
    {{ rbenv }} rubocop -a {{ args }}

# Format every Markdown file
format-markdown:
    fd .md -X mdformat --wrap no

# Run all the tests; a full run enforces 100% line and branch coverage
test *args:
    {{ rbenv }} rspec {{ args }}

# Run all tests with --documentation
test-docs *args:
    {{ rbenv }} rspec --format documentation {{ args }}

# Run tests and measure coverage even for a partial run
test-coverage *args:
    export COVERAGE=true; {{ rbenv }} rspec {{ args }}

ci: lint test-coverage

alias check-all := ci

# Remove .DS_Store files and tmp/
clean:
    fd --hidden --no-ignore --type file --glob .DS_Store --exec rm -v
    rm -rf tmp coverage

# Run all lefthook pre-commit hooks against every file
lefthook:
    lefthook run pre-commit --all-files

# Print current gem version
version:
    @echo "{{ version }}"

# Remove every generated file
clobber:
    {{ rbenv }} rake clobber

# Generate YARD documentation
doc:
    {{ rbenv }} rake doc

# Builds the gem for distribution
build:
    {{ rbenv }} rake build

# `gem push` rather than `rake release`: release also tags and pushes git,
# which `just release` does separately, and it gives no way to pass a 2FA code.
#
#   just publish            # gem push prompts for the code if 2FA needs one
#   just publish 123456     # use this code
#
# Build the .gem and push it to RubyGems
publish otp="": build
    #!/usr/bin/env bash
    set -euo pipefail
    eval "$(rbenv init - bash 2>/dev/null || true)"

    otp="{{ otp }}"
    if [[ -n "${otp}" ]]; then
      gem push "{{ gem_file }}" --otp "${otp}"
    else
      gem push "{{ gem_file }}"
    fi

    # Only reachable when the push succeeded: `set -e` aborts on a failed push.
    echo "published {{ gem_name }} {{ version }} → {{ gem_url }}"
    open "{{ gem_url }}" 2>/dev/null || xdg-open "{{ gem_url }}" 2>/dev/null || true

# Tag v{{ version }} and publish the GitHub release
release:
    git fetch --tags
    git tag -f "v{{ version }}"
    git push -f --tags
    gh release delete -y "v{{ version }}" --repo {{ repo }} 2>/dev/null || true
    gh release create "v{{ version }}" --generate-notes --repo {{ repo }}
