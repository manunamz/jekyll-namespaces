## [0.0.2] - 2021-09-17
### Changed
- `ancestors` and `children` frontmatter variables contain url strings instead of jekyll documents.
### Removed
- Graph functionality (moved to [jekyll-graph](https://github.com/manunamz/jekyll-graph/)).

## [0.0.1] - 2021-07-22
- Initial release
### Added
- Build tree data structure from filename namespaces with dot delimiters.
- Add `ancestors` and `children` frontmatter variables.
- Build d3 graph data for hierarchical graph.
- Helper functions to retrieve `relatives` and `neighbors` for tree and net-web graphs respectively (accessed in [jekyll-graph](https://github.com/manunamz/jekyll-graph/)).
