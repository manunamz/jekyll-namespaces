# frozen_string_literal: true
require "jekyll"

require_relative "jekyll-namespaces/context"
require_relative "jekyll-namespaces/node"
require_relative "jekyll-namespaces/version"

module Jekyll
  module Namespaces

    class Generator < Jekyll::Generator
      attr_accessor :site, :config

      # Use Jekyll's native relative_url filter
      include Jekyll::Filters::URLFilters

      CONVERTER_CLASS = Jekyll::Converters::Markdown
      # config
      CONFIG_KEY = "namespaces"
      ENABLED_KEY = "enabled"
      INCLUDE_KEY = "include"
      # graph config
      GRAPH_DATA_KEY = "d3_graph_data"
      ENABLED_GRAPH_DATA_KEY = "enabled"
      EXCLUDE_GRAPH_KEY = "exclude"
      GRAPH_ASSETS_LOCATION_KEY = "path"

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

        # tree
        ## setup
        root_doc = @md_docs.detect { |doc| doc.basename_without_ext == 'root' }
        root = Node.new('root', root_doc.data['id'], root_doc.data['title'], root_doc.data['permalink'], root_doc)
        ## build
        @md_docs.each do |cur_doc|
          ## add path
          if !cur_doc.data['slug'].nil? and cur_doc.data['slug'] != 'root'
            self.add_path(root, cur_doc)
          end
        end
        
        # print_tree(root)
        
        # generate tree metadata
        @md_docs.each do |cur_doc|
          if !excluded_in_graph?(cur_doc)
            cur_doc.data['namespace'] = cur_doc.basename_without_ext
            cur_doc.data['ancestors'], cur_doc.data['children'] = self.find_doc_immediate_relatives(cur_doc, root)
          end
        end
        # graph
        if !disabled_graph_data?
          self.write_graph(root)
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
        config[CONFIG_KEY] && config[CONFIG_KEY][key]
      end

      # graph config helpers

      def disabled_graph_data?
        option_graph(ENABLED_GRAPH_DATA_KEY) == false
      end

      def excluded_in_graph?(type)
        return false unless option_graph(EXCLUDE_GRAPH_KEY)
        return option_graph(EXCLUDE_GRAPH_KEY).include?(type.to_s)
      end

      def has_custom_assets_path?
        return !!option_graph(GRAPH_ASSETS_LOCATION_KEY)
      end

      def option_graph(key)
        config[GRAPH_DATA_KEY] && config[GRAPH_DATA_KEY][key]
      end

      # helpers

      # add unique path for the given doc to tree (node-class).
      def add_path(node, doc, depth=1)
        chunked_namespace = doc.data['slug'].split(/\s|\./)
        # handle doc if the given node was not root and we are at depth
        if depth == chunked_namespace.length
          cur_nd_namespace = 'root' + '.' + doc.data['slug']
          cur_nd_id = doc.data['id']
          cur_nd_title = doc.data['title']
          cur_nd_url = doc.data['permalink']
          # create node if one does not exist
          unless node.children.any?{ |c| c.namespace == cur_nd_namespace }
            new_node = Node.new(cur_nd_namespace, cur_nd_id, cur_nd_title, cur_nd_url, doc)
            node.children << new_node
          # fill-in node if one already exists
          else
            cur_node = node.children.detect {|c| c.namespace == cur_nd_namespace }
            cur_node.fill(cur_nd_id, cur_nd_title, cur_nd_url, doc)
          end
          return
        # create temp node and recurse
        else
          cur_namespace = 'root' + '.' + chunked_namespace[0..(depth - 1)].join('.')
          unless node.children.any?{ |c| c.namespace == cur_namespace }
            new_node = Node.new(cur_namespace)
            node.children << new_node
          else
            new_node = node.children.detect {|c| c.namespace == cur_namespace }
          end
        end
        self.add_path(new_node, doc, depth + 1)
      end

      # find the parent and children of the 'target_doc'.
      # ('node' as in the current node, which first is root.)
      def find_doc_immediate_relatives(target_doc, node, ancestors=[])
        if target_doc == node.doc
          children = []
          node.children.each do |child|
            if !child.doc.is_a?(Jekyll::Document)
              children << ""
            else
              children << child.doc.url
            end
          end
          return ancestors, children
        else
          if !node.doc.is_a?(Jekyll::Document)
            ancestors << ""
          else
            ancestors << node.doc.url
          end
          results = []
          node.children.each do |child_node|
            results.concat self.find_doc_immediate_relatives(target_doc, child_node, ancestors.clone)
          end
          return results.select { |r| !r.nil? }
        end
      end

      # ...for debugging
      def print_tree(node, ancestors=[])
        Jekyll.logger.warn "Ancestors: ", ancestors.length
        Jekyll.logger.warn node
        Jekyll.logger.warn "Children: ", node.children
        ancestors.append(node.id)
        node.children.each do |child_node|
          self.print_tree(child_node, ancestors.clone)
        end
      end

      # graph helpers

      # convert tree (node-class) to json
      def tree_to_json(baseurl, node, json_node={})
        if !node.doc.is_a?(Jekyll::Document)
          Jekyll.logger.warn "Tree node missing: ", node.namespace
          label = node.namespace.match('([^.]*$)')[0].gsub('-', ' ')
          node_url = ''
        else
          label = node.title
          node_url = relative_url(node.doc.url)
        end
        json_children = []
        node.children.each do |child|
          new_child = self.tree_to_json(baseurl, child)
          json_children.append(new_child)
        end
        json_node = {
          # "id": node.id,
          "id": node_url,
          "namespace": node.namespace,
          "label": label,
          "children": json_children,
          "url": node_url,
        }
        return json_node
      end

      def write_graph(root)
        assets_path = has_custom_assets_path? ? option_graph(GRAPH_ASSETS_LOCATION_KEY) : "/assets"
        if !File.directory?(File.join(site.source, assets_path))
          Jekyll.logger.error "Assets location does not exist, please create required directories for path: ", assets_path
        end
        # from: https://github.com/jekyll/jekyll/issues/7195#issuecomment-415696200
        static_file = Jekyll::StaticFile.new(site, site.source, assets_path, "graph-tree.json")
        json_formatted_tree = self.tree_to_json(@site.baseurl, root)
        File.write(@site.source + static_file.relative_path, JSON.dump(
          json_formatted_tree
        ))
        # tests fail without manually adding the static file, but actual site builds seem to do ok
        # ...although there does seem to be a race condition which causes a rebuild to be necessary in order to detect the graph data file
        if @testing
          @site.static_files << static_file if !@site.static_files.include?(static_file)
        end
      end
    end

  end
end
