# Run with: RAILS_ENV=production bundle exec rails runner plugins/redmine_tags/test/release_smoke.rb
require 'json'
require 'securerandom'

def check_tags_release(condition, message)
  raise message unless condition
  puts "PASS: #{message}"
end

previous_user = User.current
begin
  ActiveRecord::Base.transaction do
    admin = User.active.where(admin: true).first!
    User.current = admin
    check_tags_release(Redmine::Plugin.find(:redmine_tags).version == '1.1.0', 'plugin version 1.1.0')
    suffix = SecureRandom.hex(6)
    tracker = Tracker.first!
    project = Project.create!(name: "Tags release #{suffix}", identifier: "tags-release-#{suffix}",
                              is_public: true, tracker_ids: [tracker.id],
                              enabled_module_names: %w[issue_tracking wiki])
    issue = Issue.create!(project: project, tracker: tracker, author: admin,
                          status: IssueStatus.first!, priority: IssuePriority.first!,
                          subject: 'Temporary tags release check',
                          tag_list: ["release-a-#{suffix}", "release-b-#{suffix}"])
    names = issue.reload.tags.pluck(:name).sort
    check_tags_release(names.size == 2, 'issue tags persist')
    check_tags_release(Issue.tagged_with(names.first).exists?(issue.id), 'issue tag filtering')

    wiki = project.wiki || Wiki.create!(project: project, start_page: 'Wiki')
    page = WikiPage.new(wiki: wiki, title: "TagsRelease#{suffix}", tag_list: [names.first])
    page.content = WikiContent.new(text: 'Temporary wiki tag check', author: admin)
    page.save!
    check_tags_release(page.reload.tags.pluck(:name) == [names.first], 'wiki tags persist')

    Setting.rest_api_enabled = '1'
    session = ActionDispatch::Integration::Session.new(Rails.application)
    session.host! 'localhost'
    headers = { 'X-Redmine-API-Key' => admin.api_key }
    session.get "/issues/#{issue.id}.json", params: { include: 'tags' }, headers: headers
    check_tags_release(session.response.status == 200, 'issue JSON API responds')
    data = JSON.parse(session.response.body).fetch('issue')
    check_tags_release(data.fetch('tags').map { |tag| tag.fetch('name') }.sort == names,
                       'issue JSON API includes tag names')
    session.get "/projects/#{project.id}.json", params: { include: 'tags' }, headers: headers
    check_tags_release(session.response.status == 200, 'project JSON API responds')
    data = JSON.parse(session.response.body).fetch('project')
    check_tags_release(data.fetch('tags').map { |tag| tag.fetch('name') }.sort == names,
                       'project JSON API includes issue tags')

    first, second = issue.tags.order(:id).to_a
    ActsAsTaggableOn::Tagging.where(tag_id: second.id).update_all(tag_id: first.id)
    TagsController.new.send(:remove_duplicate_taggings, first)
    second.destroy!
    check_tags_release(issue.reload.tags.pluck(:id) == [first.id], 'merged issue tags are deduplicated')
    check_tags_release(page.reload.tags.pluck(:id) == [first.id], 'merge preserves wiki assignments')
    check_tags_release(first.reload.taggings_count == ActsAsTaggableOn::Tagging.where(tag_id: first.id).count,
                       'merge repairs the tag counter cache')
    raise ActiveRecord::Rollback
  end
ensure
  User.current = previous_user
  Setting.clear_cache
end
puts 'Redmine Tags release smoke check passed; temporary database changes rolled back.'
