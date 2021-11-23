# Jekyll-Namespaces

⚠️ This is gem is under active development! ⚠️

⚠️ Expect breaking changes and surprises until otherwise noted (likely by v0.1.0 or v1.0.0). ⚠️

Jekyll-Namespaces provides support for long namespacing of markdown filenames with dot `.` delimiters. Frontmatter metadata is added to each document so that they may be referenced by the relationships that make up the overarching hierarchy built from the namespaces. (For example, on a page it may be desirable to link to all `children` of the current page or to build a breadcrumb trail from the current page's ancestry.)

This gem works in conjunction with [`jekyll-graph`](https://github.com/manunamz/jekyll-graph).

This gem is part of the [jekyll-bonsai](https://manunamz.github.io/jekyll-bonsai/) project. 🎋

## Installation

Follow the instructions for installing a [jekyll plugin](https://jekyllrb.com/docs/plugins/installation/) for `jekyll-namespaces`.

## Configuration

Defaults look like this:

```yaml
namespaces:
  enabled: true
  exclude: []
```

`enabled`: Toggles the plugin on or off.

`exclude`: A list of any jekyll document type (`pages`, `posts`, and `collections`. [Here](https://ben.balter.com/2015/02/20/jekyll-collections/) is a post on them) to exclude from the namespace tree.

## Usage

Namespaces are delineated by dots, `like.this.md`. There must also be a root document named `root.md`.

Missing levels will not break the build. They will be processed and marked as missing by replacing urls with the namespaced filename.

### Metadata

`ancestors`: Contains a list of url strings for documents along the path from the root document to the current document in the tree.

`children`: Contains a list of url strings of all immediate children of the current document.

`siblings`: Contains a list of url strings of all nodes that share the same direct parent as the current node.

The document for the url can be retrieved in liquid templates like so:

```html
<!-- print all ancestors as links with the document title as its innertext -->

{% for ancestor_url in page.ancestors %}
    {% assign ancestor_doc = site.documents | where: "url", ancestor_url | first %}
    <a href="{{ ancestor_doc.url }}">{{ ancestor_doc.title }}</a>
{% endfor %}
```
```html
<!-- print all children as links with the document title as its innertext -->

{% for child_url in page.children %}
    {% assign child_doc = site.documents | where: "url", child_url | first %}
    <a href="{{ child_doc.url }}">{{ child_doc.title }}</a>
{% endfor %}
```
