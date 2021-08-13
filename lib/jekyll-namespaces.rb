# frozen_string_literal: true
require "jekyll"

require_relative "jekyll-namespaces/context"
require_relative "jekyll-namespaces/site"
require_relative "jekyll-namespaces/tree"
require_relative "jekyll-namespaces/version"

module Jekyll
  module Namespaces

    class Generator < Jekyll::Generator
      attr_accessor :site, :config

      CONVERTER_CLASS = Jekyll::Converters::Markdown
      # config
      CONFIG_KEY = "namespaces"
      ENABLED_KEY = "enabled"
      INCLUDE_KEY = "include"

      def initialize(config)
        @config ||= config
        @testing ||= config['testing'] if config.keys.include?('testing')
      end

      def generate(site)
        return if disabled?

        # setup site
        @site = site
        @context ||= Context.new(site)

        # setup markdown docs
        docs = []
        docs += @site.pages if include?(:pages)
        docs += @site.docs_to_write.filter { |d| include?(d.type) }
        @md_docs = docs.filter { |doc| markdown_extension?(doc.extname) }

        # tree setup
        root_doc = @md_docs.detect { |doc| doc.basename_without_ext == 'root' }
        @site.tree = Tree.new(root_doc, @md_docs)

        # generate metadata
        @md_docs.each do |cur_doc|
          if !include?(cur_doc)
            cur_doc.data['namespace'] = cur_doc.basename_without_ext
            cur_doc.data['ancestors'], cur_doc.data['children'] = @site.tree.find_doc_immediate_relatives(cur_doc)
          end
        end


      end

      # config helpers

      def disabled?
        option(ENABLED_KEY) == false
      end

      def include?(type)
        return false unless option(INCLUDE_KEY)
        return option(INCLUDE_KEY).include?(type.to_s)
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
    end

  end
end
