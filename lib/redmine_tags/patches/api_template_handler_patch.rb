module RedmineTags
  module Patches
    module ApiTemplateHandlerPatch
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
          class << self
            alias_method :call_without_redmine_tags, :call
            alias_method :call, :call_with_redmine_tags
          end
        end
      end

      module ClassMethods
        def call_with_redmine_tags(template, source = nil)
          source = redmine_tags_expand_source(template, source)
          call_without_redmine_tags(template, source)
        end

        private

        # Injects the plugin's "<template>_with_tags.api.rsb" snippet into the
        # matching core API template. The last line of the snippet doubles as the
        # anchor that is replaced in the core template.
        def redmine_tags_expand_source(template, source)
          source ||= template.source
          return source if template.instance_variable_get(:@redmine_tags_expanded)

          ActionController::Base.view_paths.each do |path|
            snippet_path = "#{path}/#{template.virtual_path}_with_tags.api.rsb"
            next unless File.exist?(snippet_path)

            lines = File.readlines(snippet_path)
            next if lines.empty?

            # Match the anchor independently of the line ending: the core
            # templates may be checked out with CRLF while the snippet uses LF,
            # in which case a plain String#sub matches nothing and the API
            # silently returns no tags at all.
            anchor  = Regexp.escape(lines.last.chomp)
            snippet = lines.map { |line| "#{line.chomp}\n" }.join
            source  = source.sub(/#{anchor}[ \t]*\r?\n?/) { snippet }
          end

          # Since Rails 7 a file backed template keeps its source as an
          # ActionView::Template::Sources::File whose #to_s re-reads the file on
          # every call, so mutating template.source in place is lost. Replace the
          # source object with the expanded String instead.
          template.instance_variable_set(:@source, source)
          template.instance_variable_set(:@redmine_tags_expanded, true)
          source
        end
      end
    end
  end
end

base = Redmine::Views::ApiTemplateHandler
patch = RedmineTags::Patches::ApiTemplateHandlerPatch
base.send(:include, patch) unless base.included_modules.include?(patch)
