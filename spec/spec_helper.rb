# frozen_string_literal: true

require "jekyll-namespaces"

# Jekyll.logger.log_level = :error

RSpec.configure do |config|
  FIXTURES_DIR = File.expand_path("fixtures", __dir__)
  SITE_DIR = File.expand_path("_site", __dir__)

  def fixtures_dir(*files)
    File.join(FIXTURES_DIR, *files)
  end

  def site_dir(*files)
    File.join(SITE_DIR, *files)
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # expected retrieval helpers

  def find_by_title(docs, title)
    docs.find { |d| d.data["title"] == title }
  end

  def find_generated_file(relative_path)
    fixtures_dir(relative_path)
  end

  def find_static_file(relative_path)
    site.static_files.find { |sf| sf.relative_path == relative_path }
  end

  # comments from: https://github.com/jekyll/jekyll-mentions/blob/master/spec/spec_helper.rb

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # comments from: https://github.com/jekyll/jekyll-mentions/blob/master/spec/spec_helper.rb

  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  
  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
end
