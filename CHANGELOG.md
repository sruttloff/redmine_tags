# Changelog

## Unreleased

- Remove upstream development tooling configured for Ruby 3.1 and Rails 6.1.
- Remove CI configuration tied to the tools-aoeur Redmine fork and its test database files.
- Remove legacy RSpec and Redmine test files without a working test setup in this fork.
- Keep the transactional Redmine 6.1 release smoke check.

## 1.1.0 — 2026-10-12

First release of the SaaS-Secure.com fork for Redmine 6.1, based on the
`redmine-6.1` branch of tools-aoeur/redmine_tags.

- Import the locally adapted plugin while preserving the upstream Git history.
- Use Active Record's `update` method when renaming tags.
- Create merge targets from an explicit tag name.
- Deduplicate merged tag assignments and repair their counter cache.
- Adapt API template expansion to Rails file-backed sources and mixed LF/CRLF
  line endings so issue and project responses retain their tags.
- Keep the local runtime Gemfile without optional upstream lint dependencies.
- Update the plugin URL and version, and expand the README with installation,
  setup, usage, API, support, and license information.
- Add a transactional release smoke check for the local Redmine environment.

Validation environment: Redmine 6.1.2-stable, Rails 7.2.3, Ruby 3.3.7,
MySQL 8.4.11, and acts-as-taggable-on 13.0.0. See the README for validation
coverage and limitations.
