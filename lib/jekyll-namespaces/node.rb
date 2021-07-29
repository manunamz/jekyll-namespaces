# frozen_string_literal: true

# helper class for tree-building.
class Node
  attr_accessor :id, :namespace, :title, :children, :url, :doc

  def initialize(id, namespace, title, url, doc)
    @id = id.to_s
    @children = []
    @namespace = namespace
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