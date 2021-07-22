# frozen_string_literal: true

require "jekyll-namespaces"
require "spec_helper"

RSpec.describe(JekyllNamespaces) do

  it "has a version number" do
    expect(JekyllNamespaces::VERSION).not_to be nil
  end

end

RSpec.describe(JekyllNamespaces::Generator) do
  let(:config) do
    Jekyll.configuration(
      config_overrides.merge(
        "collections"          => { "docs" => { "output" => true } },
        "permalink"            => "pretty",
        "skip_config_files"    => false,
        "source"               => fixtures_dir,
        "destination"          => site_dir,
        "url"                  => "garden.testsite.com",
        # "testing"              => true,
        # "baseurl"              => "",
      )
    )
  end
  # let(:config_overrides)     { {} }
  let(:config_overrides)     { { "namespaces" => { "exclude" => ["pages", "posts"] } } }
  let(:site)                 { Jekyll::Site.new(config) }
  
  let(:doc_root)             { find_by_title(site.collections["docs"].docs, "Root") }
  let(:doc_second_lvl)       { find_by_title(site.collections["docs"].docs, "Root Second Level") }
  let(:doc_missing_lvl)      { find_by_title(site.collections["docs"].docs, "Missing Level") }

  # makes markdown tests work
  subject                    { described_class.new(site.config) }

  before(:each) do
    site.reset
    site.process
  end

  after(:each) do
    # cleanup generated assets
    FileUtils.rm_rf(Dir["#{fixtures_dir("/assets/graph-tree.json")}"])
    # cleanup _site/ dir
    FileUtils.rm_rf(Dir["#{site_dir()}"])
  end

  it "saves the config" do
    expect(subject.config).to eql(site.config)
  end

  context "processes markdown" do

    context "detecting markdown" do
      before { subject.instance_variable_set "@site", site }

      it "knows when an extension is markdown" do
        expect(subject.send(:markdown_extension?, ".md")).to eql(true)
      end

      it "knows when an extension isn't markdown" do
        expect(subject.send(:markdown_extension?, ".html")).to eql(false)
      end

      it "knows the markdown converter" do
        expect(subject.send(:markdown_converter)).to be_a(Jekyll::Converters::Markdown)
      end
    end

  end

end
