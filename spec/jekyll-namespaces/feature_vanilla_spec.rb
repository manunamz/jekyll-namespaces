# frozen_string_literal: true

require "jekyll-namespaces"
require "spec_helper"

RSpec.describe(Jekyll::Namespaces::Generator) do
  let(:config) do
    Jekyll.configuration(
      config_overrides.merge(
        "collections"          => { "docs" => { "output" => true } },
        "permalink"            => "pretty",
        "skip_config_files"    => false,
        "source"               => fixtures_dir,
        "destination"          => site_dir,
        "url"                  => "garden.testsite.com",
        "testing"              => true,
        # "baseurl"              => "",
      )
    )
  end
  # let(:config_overrides)     { {} }
  let(:config_overrides)     { { "namespaces" => { "include" => ["docs"] } } }
  let(:site)                 { Jekyll::Site.new(config) }
  
  let(:doc_root)             { find_by_title(site.collections["docs"].docs, "Root") }
  let(:doc_second_lvl)       { find_by_title(site.collections["docs"].docs, "Root Second Level") }
  let(:doc_third_lvl)        { find_by_title(site.collections["docs"].docs, "Root Third Level") }
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

  context "basic tree.path processing" do

    context "when tree.path exists" do

      it "root-lvl 'ancestors' and 'children' metadata will be populated" do
        expect(doc_root.data['ancestors'].size).to eq(0)
        expect(doc_root.data['children'].size).to eq(2)
        expect(doc_root.data['children']).to include(doc_second_lvl)
        expect(doc_root.data['children']).to include({ "url" => "", "title" => "blank" })
      end

      it "second-lvl 'ancestors' and 'children' metadata will be populated" do
        expect(doc_second_lvl.data['ancestors'].size).to eq(1)
        expect(doc_second_lvl.data['ancestors']).to include(doc_root)
        expect(doc_second_lvl.data['children'].size).to eq(1)
        expect(doc_second_lvl.data['children']).to include(doc_third_lvl)
      end

      it "third-lvl 'ancestors' and 'children' metadata will be populated" do
        expect(doc_third_lvl.data['ancestors'].size).to eq(2)
        expect(doc_third_lvl.data['ancestors']).to include(doc_root)
        expect(doc_third_lvl.data['ancestors']).to include(doc_second_lvl)
        expect(doc_third_lvl.data['children'].size).to eq(0)
      end

    end

    context "when tree.path level does not exist" do

      it "parent of missing level inserts placeholders in 'children' for missing levels" do
        expect(doc_root.data['children']).to include({ "url" => "", "title" => "blank" })
      end

      it "child of missing level  inserts placeholders in 'ancestors' for missing levels" do
        expect(doc_missing_lvl.data['ancestors'].size).to eq(2)
        expect(doc_missing_lvl.data['ancestors']).to include({ "url" => "", "title" => "blank" })
      end  

    end

  end

end