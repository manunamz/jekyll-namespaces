# Jekyll-Namespaces

⚠️ This is gem is under active development! ⚠️ 

⚠️ Expect breaking changes and surprises until otherwise noted (likely by v0.1.0 or v1.0.0). ⚠️

## Installation

1. Add `gem 'jekyll-namespaces'` to your site's Gemfile and run `bundle`.
2. You may edit `_config.yml` to toggle the plugin and graph generation on/off or exclude certain jekyll types. (jekyll types: `pages`, `posts`, and `collections`. [Here](https://ben.balter.com/2015/02/20/jekyll-collections/) is a blog post about them.)

Defaults look like this:

```
namespaces:
  enable: true
  include: []
d3_graph_data:
  enabled: true
  exclude: []
  path: "/assets"
```

The `enable` flags may be toggled to turn off the plugin or turn off `d3_graph_data` generation. Any jekyll type ("pages", "posts", or collection names such as "docs" or "notes") may be added to a list of `include`s for namespaces or `exclude`s for graph generation.

The gem will only scan the jekyll types listed under the `include` config:

```
namespaces:
  include:
    - "docs"
```

## Usage

Namespaces are dilineated by dots, `like.this.md`.

Metadata is added to frontmatter of processed documents:
  - `ancestors`: An ("ordered") array of ancestor documents of the current doc.
  - `children`: The child documents of the current doc (only goes one level deep -- e.g. there are no grandchildren).

Missing levels will not break the build. They will be processed and marked as missing.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/manunamz/jekyll-namespaces.
