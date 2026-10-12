# Redmine Tags for Redmine 6.1

Redmine Tags adds tags to issues and wiki pages. Use tags to organize content across trackers, filter issue lists, and find related issues and wiki pages.

This fork is maintained for Redmine 6.1 by **[SaaS-Secure.com, S. Ruttloff](https://www.saas-secure.com/)**. It continues the work of [Redmine Tags by ixti](https://github.com/ixti/redmine_tags) and the [tools-aoeur fork](https://github.com/tools-aoeur/redmine_tags). The original project's unmaintained notice applies to upstream; issues for this fork belong in this repository.

**Version: 1.1.0.** The local validation environment uses Redmine **6.1.2-stable**, Rails **7.2.3**, Ruby **3.3.7**, MySQL **8.4.11**, and `acts-as-taggable-on` **13.0.0**. See [validation](#validation-and-development) for the checks and their limits, and the [changelog](CHANGELOG.md) for release notes. The plugin declares Redmine 5.0 as its minimum version; compatibility with older Redmine releases and other database adapters has not been confirmed for this release.

## Features

- Add and remove issue tags with autocomplete suggestions.
- Edit tags for multiple issues using Redmine's bulk edit form.
- Filter issue lists by tags and display tags as an issue-list column.
- Include tags when copying issues and record tag changes in issue history.
- Tag wiki pages and include tag names in Redmine's issue and wiki searches.
- Display tags in the sidebar as a list, cloud, or simple cloud, with optional counts and colors.
- Rename, merge, and delete tags centrally as an administrator.
- Include issue tags and project issue-tag summaries in JSON/XML API responses.

## Requirements

- Redmine 6.1 and the Ruby/Rails versions supported by that release for the maintained configuration.
- The `acts-as-taggable-on` gem listed in the plugin's `Gemfile`.
- A database and plugin-directory backup before installation or upgrade.

The plugin uses the `tags` and `taggings` tables. Other plugins may share these tables; check your installed plugins before migrating or removing them.

## Installation

Check out the published version in Redmine's plugin directory. The directory must be named exactly `redmine_tags`:

```sh
cd /path/to/redmine/plugins
git clone --branch v1.1.0 https://github.com/sruttloff/redmine_tags.git redmine_tags
cd /path/to/redmine
bundle install
bundle exec rake redmine:plugins:migrate NAME=redmine_tags RAILS_ENV=production
```

If your installation uses precompiled assets, rebuild them next:

```sh
bundle exec rake assets:precompile RAILS_ENV=production
```

Then restart the Redmine application server using the procedure for your deployment, such as Puma under systemd, Passenger, or Docker.

For an upgrade, back up the database and plugin directory, fetch and check out the desired tag, and repeat the steps for gems, migrations, assets, and restarting:

```sh
cd /path/to/redmine/plugins/redmine_tags
git fetch origin --tags
git checkout v1.1.0
```

Keep local modifications in a separate commit before switching versions.

## Setup

1. Open **Administration → Plugins → Redmine Tags → Configure**.
2. On the **General** tab, choose the sidebar display: **None**, **List**, **Cloud**, or **Simple cloud**. The default is **None**.
3. Optionally enable issue counts, restrict the issue sidebar to open issues, choose sorting by name or issue count, and enable colors.
4. Use the **Manage tags** tab to rename, merge, or delete existing tags. Tag management requires an administrator and affects every object using those tags.

The plugin does not introduce a separate project module or custom role permissions. Access to issue and wiki editing follows Redmine's existing permissions and workflow restrictions.

## Usage

- **Issues:** Open an issue's edit form, enter tags in the Tags field, accept a suggestion or add a new tag, and save the issue. Remove a tag using its remove control.
- **Bulk editing:** Select issues in the issue list and open the bulk edit form to change their tags.
- **Issue lists:** Add the Tags filter or column to a query. Save the query to reuse the same view.
- **Wiki:** Edit a wiki page and enter its tags in the Tags field. Tags appear with the page and can be used to find related content.
- **Administration:** Select tags on the Manage tags tab and use the context menu to rename, merge, or delete them. Merging combines their assignments and removes duplicate assignments.

### REST API

Enable Redmine's REST API under **Administration → Settings → API** and authenticate with an API key. The plugin extends Redmine's existing endpoints, for example:

```sh
curl -H 'X-Redmine-API-Key: YOUR_API_KEY' \
  'https://redmine.example.com/issues/123.json?include=tags'
```

With `include=tags`, issue responses contain a `tags` array with tag IDs and names. Project responses support the same parameter and contain a tag summary for visible issues. Tags can be submitted through the issue API using the `tag_list` attribute, subject to the usual issue permissions. This plugin does not provide a standalone public tag-management REST API.

### Localization

The plugin includes English, German, and additional upstream translations. Translation completeness varies by language; some German tag-management labels currently fall back to English. Tag names entered by users are not translated.

## Changes in this fork

- Update tag renaming to use the current Active Record API.
- Create merged tags from an explicit name rather than passing controller parameters directly to the model.
- Remove duplicate assignments after a merge and repair the tag counter cache.
- Preserve tags in API output with Rails file-backed templates and mixed LF/CRLF line endings.
- Document installation, configuration, usage, compatibility, and release history.

## Validation and development

Run the release smoke check in a Redmine installation with the plugin's migrations applied and at least one administrator, tracker, issue status, and issue priority:

```sh
RAILS_ENV=production bundle exec rails runner plugins/redmine_tags/test/release_smoke.rb
```

The check verifies plugin registration, tag persistence, issue and project JSON API output, tag filtering, wiki tag persistence, and merge deduplication with counter repair. It uses temporary records inside a rolled-back database transaction. Run it on a development or staging installation with no concurrent writes.

The release smoke check does not establish complete browser, XML, permissions, reload, or cross-database compatibility. The former upstream CI matrix and legacy test files targeted a different Redmine fork and are no longer part of this fork.

## More plugins from SaaS-Secure.com

- **[Redmine UX Toolkit](https://www.saas-secure.com/online-services/redmine-ux-toolkit.html)** – Interface improvements, dashboards, checklists, templates, reminders, and administration tools.
- **[SCM Creator for Redmine](https://www.saas-secure.com/online-services/redmine-scm.html)** – Repository management for Git, Subversion, Mercurial, Bazaar, and GitHub.

These plugins are optional additions. For hosting and other services, visit **[www.saas-secure.com](https://www.saas-secure.com/)**.

## Support and credits

Report issues through **[GitHub Issues](https://github.com/sruttloff/redmine_tags/issues)**. Include your Redmine, Ruby, Rails, database, and `acts-as-taggable-on` versions and steps to reproduce the problem.

- Original authors: Eric Davis and Aleksey V Zapparov (ixti), with the Redmine Tags contributors.
- Upstream adaptations: [tools-aoeur/redmine_tags](https://github.com/tools-aoeur/redmine_tags).
- Maintenance of this fork: [SaaS-Secure.com, S. Ruttloff](https://www.saas-secure.com/).

## License

Redmine Tags is licensed under the **GNU General Public License, version 3 or later**. Original copyright notices are preserved; see [COPYING](COPYING) and [LICENSE](LICENSE).
