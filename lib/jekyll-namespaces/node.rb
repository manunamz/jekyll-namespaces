# frozen_string_literal: true

# helper class for tree-building.
class Node
  attr_accessor :id, :namespace, :title, :children, :doc

  def initialize(id, namespace, title, doc)
    @id = id
    @children = []
    @namespace = namespace
    @title = title
    @doc = doc
  end

  def type
    return doc.type
  end

  def to_s
    "namespace: #{@namespace}"
  end
end