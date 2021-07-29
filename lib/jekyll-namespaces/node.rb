# frozen_string_literal: true

# helper class for tree-building.
class Node
  attr_accessor :id, :namespace, :title, :children, :url, :doc

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

  def type
    return doc.type
  end

  def to_s
    "namespace: #{@namespace}"
  end
end
