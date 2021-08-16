# frozen_string_literal: true
require "jekyll"

require_relative "jekyll-namespaces/context"
require_relative "jekyll-namespaces/site"
require_relative "jekyll-namespaces/tree"
require_relative "jekyll-namespaces/version"

module Jekyll
  module Namespaces

    class Generator < Jekyll::Generator
      # for testing
      attr_reader :config

      CONVERTER_CLASS = Jekyll::Converters::Markdown
      # config
      CONFIG_KEY = "namespaces"
      ENABLED_KEY = "enabled"
      EXCLUDE_KEY = "exclude"

      def initialize(config)
        @config ||= config
      end

      def generate(site)
        return if disabled?
        self.old_config_warn()

        # setup site
        @site = site
        @context ||= Context.new(site)

        # setup markdown docs
        docs = []
        docs += @site.pages if !excluded?(:pages)
        docs += @site.docs_to_write.filter { |d| !excluded?(d.type) }
        @md_docs = docs.filter { |doc| markdown_extension?(doc.extname) }
        return if @md_docs.empty?

        # tree setup
        root_doc = @md_docs.detect { |doc| doc.data['slug'] == 'root' }
        @site.tree = Tree.new(root_doc, @md_docs)

        # generate metadata
        @md_docs.each do |cur_doc|
          cur_doc.data['namespace'] = cur_doc.data['slug']
          cur_doc.data['ancestors'], cur_doc.data['children'] = @site.tree.find_doc_immediate_relatives(cur_doc)
        end

      end

      # config helpers

      def disabled?
        option(ENABLED_KEY) == false
      end

      def excluded?(type)
        return false unless option(EXCLUDE_KEY)
        return option(EXCLUDE_KEY).include?(type.to_s)
      end

      def markdown_extension?(extension)
        markdown_converter.matches(extension)
      end

      def markdown_converter
        @markdown_converter ||= @site.find_converter_instance(CONVERTER_CLASS)
      end

      def option(key)
        @config[CONFIG_KEY] && @config[CONFIG_KEY][key]
      end

      # !! deprecated !!

      def option_exist?(key)
        @config[CONFIG_KEY] && @config[CONFIG_KEY].include?(key)
      end

      def old_config_warn()
        if @config.include?("d3_graph_data")
          Jekyll.logger.warn "As of 0.0.2, 'd3_graph_data' should now be 'd3' and requires the 'jekyll-d3' plugin."
        end
        if option_exist?("include")
          Jekyll.logger.warn "As of 0.0.2, all markdown files are processed by default. Use 'exclude' config to exclude document types."
        end
      end
    end

  end
end
