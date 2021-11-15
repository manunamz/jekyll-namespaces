# frozen_string_literal: true
require "jekyll"

module Jekyll

  class Tree
    attr_reader :root

    def initialize(root_doc, md_docs)
      @root = Node.new('root', root_doc.data['id'], root_doc.data['title'], root_doc.url, root_doc)

      md_docs.each do |doc|
        if doc != @root.doc
          # jekyll pages don't have the slug attribute: https://github.com/jekyll/jekyll/blob/master/lib/jekyll/page.rb#L8
          if doc.type == :pages
            page_basename = File.basename(doc.name, File.extname(doc.name))
            doc.data['slug'] = Jekyll::Utils.slugify(page_basename)
          end
          self.add_path(doc)
        end
      end

      # print_tree(root)
    end

    # add unique path for the given doc to tree (node-class).
    def add_path(doc, node=nil, depth=1)
      node = @root if depth == 1
      Jekyll.logger.error("Jekyll-Namespaces: Incorrect node in tree.add_path") if node == nil
      levels = doc.data['slug'].split(/\s|\./)
      # handle doc if the given node was not root and we are at depth
      if depth == levels.length
        cur_nd_namespace = 'root' + '.' + doc.data['slug']
        cur_nd_id = doc.data['id']
        cur_nd_title = doc.data['title']
        cur_nd_url = doc.url

        cur_node = node.children.detect {|c| c.namespace == cur_nd_namespace }
        # create node if one does not exist
        if cur_node.nil?
          new_node = Node.new(cur_nd_namespace, cur_nd_id, cur_nd_title, cur_nd_url, doc)
          node.children << new_node
        # fill-in node if one already exists
        else
          cur_node.fill(cur_nd_id, cur_nd_title, cur_nd_url, doc)
        end
        return
      # create temp node and recurse
      else
        cur_namespace = 'root' + '.' + levels[0..(depth - 1)].join('.')
        unless node.children.any? { |c| c.namespace == cur_namespace }
          new_node = Node.new(cur_namespace)
          node.children << new_node
        else
          new_node = node.children.detect { |c| c.namespace == cur_namespace }
        end
      end
      self.add_path(doc, new_node, depth + 1)
    end

    def get_all_relative_ids(target_node_id, node=@root, ancestors=[], descendents=[], found=false)
      # found target node, stop adding ancestors and build descendents
      if target_node_id == node.url || target_node_id == node.namespace || found
        node.children.each do |child_node|
          # if the child document is an empty string, it is a missing node
          if child_node.missing
            descendents << child_node.namespace
          else
            descendents << child_node.doc.url
          end
          self.get_all_relative_ids(target_node_id, child_node, ancestors.clone, descendents, found=true)
        end
        return ancestors, descendents
      # target node not yet found, build ancestors
      else
        # if the node document is an empty string, it is a missing node
        if node.missing
          ancestors << node.namespace
        else
          ancestors << node.doc.url
        end
        results = []
        node.children.each do |child_node|
          results.concat(self.get_all_relative_ids(target_node_id, child_node, ancestors.clone))
        end
        return results.select { |r| !r.nil? }
      end
    end


    def get_sibling_ids(target_node_id, node=@root, parent=nil)
      return [] if target_node_id === @root.url
      # found target node
      if target_node_id == node.url || target_node_id == node.namespace
        return parent.children.select { |c| c.id }
      # target node not yet found
      else
        node.children.each do |child_node|
          self.get_sibling_ids(target_node_id, child_node, node)
        end
      end
    end

    # find the parent and children of the 'target_doc'.
    # ('node' as in the current node, which first is root.)
    def find_doc_immediate_relatives(target_doc, node=nil, ancestors=[])
      node = @root if ancestors == []
      Jekyll.logger.error("Jekyll-Namespaces: Incorrect node in tree.find_doc_immediate_relatives") if node == nil
      if target_doc == node.doc
        children = []
        node.children.each do |child|
          # if the child document is an empty string, it is a missing node
          if child.missing
            children << child.namespace
          else
            children << child.doc.url
          end
        end
        return ancestors, children
      else
        # if the node document is an empty string, it is a missing node
        if node.missing
          ancestors << node.namespace
        else
          ancestors << node.doc.url
        end
        results = []
        node.children.each do |child_node|
          results.concat(self.find_doc_immediate_relatives(target_doc, child_node, ancestors.clone))
        end
        return results.select { |r| !r.nil? }
      end
    end

    # ...for debugging
    def print_tree(node, ancestors=[])
      Jekyll.logger.warn("Jekyll-Namespaces: ")
      Jekyll.logger.warn("Ancestors: #{ancestors.length}; #{node}; Children: #{node.children}")
      ancestors.append(node.id)
      node.children.each do |child_node|
        self.print_tree(child_node, ancestors.clone)
      end
    end
  end

  class Node
    attr_accessor :namespace, :id, :title, :children, :url, :doc

    def initialize(namespace, id="", title="", url="", doc="")
      # mandatory
      @namespace = namespace
      # optional
      @id = id.to_s
      @title = title
      @url = url.nil? ? "" : url
      @doc = doc
      # auto-init
      @children = []
    end

    def fill(id, title, url, doc)
      @id = id
      @title = title
      @url = url
      @doc = doc
    end

    def missing
      return @doc == ""
    end

    def type
      return @doc.type
    end

    def to_s
      "namespace: #{@namespace}"
    end
  end

end
