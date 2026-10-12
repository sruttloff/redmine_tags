require_relative 'lib/redmine_tags'

Redmine::Plugin.register :redmine_tags do
  name        'Redmine Tags'
  author      'Aleksey V Zapparov AKA "ixti"'
  description 'Redmine tagging support'
  version     '1.1.0'
  url         'https://github.com/sruttloff/redmine_tags'

  requires_redmine version_or_higher: '5.0.0'

  settings \
    default: {
      issues_sidebar: 'none',
      issues_show_count: 0,
      issues_open_only: 0,
      issues_sort_by: 'name',
      issues_sort_order: 'asc'
    },
    partial: 'tags/settings'
end

# see https://www.redmine.org/issues/36245#note-11 and following for changes with zeitwerk autoloading
Rails.application.config.after_initialize do
  paths = '/lib/redmine_tags/{patches/*_patch,hooks/*_hook}.rb'
  Dir.glob(File.dirname(__FILE__) + paths).each do |file|
    require_dependency file
  end
end
