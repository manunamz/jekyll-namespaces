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
  let(:config_overrides)     { {} }
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
    # cleanup _site/ dir
    FileUtils.rm_rf(Dir["#{site_dir()}"])
  end

  context "basic default tree.path processing" do

    context "when tree.path level exists" do

      context "metadata:" do

        it "'children' is an array of doc urls" do
          expect(doc_second_lvl.data['children']).to be_a(Array)
          expect(doc_second_lvl.data['children'][0]).to eq("/docs/second-level.third-level/")
        end

        it "'ancestors' is an array of doc urls" do
          expect(doc_second_lvl.data['ancestors']).to be_a(Array)
          expect(doc_second_lvl.data['ancestors'][0]).to eq("/docs/root/")
        end

      end

      context "what each level looks like at:" do

        it "root-lvl ('ancestors': 0; 'children': 2; w/ urls)" do
          expect(doc_root.data['ancestors'].size).to eq(0)
          expect(doc_root.data['children'].size).to eq(3)
          expect(doc_root.data['children']).to eq(["/2020/12/08/one-post/", "root.blank", "/docs/second-level/"])
        end

        it "second-lvl ('ancestors': 1; 'children': 1; w/ urls)" do
          expect(doc_second_lvl.data['ancestors'].size).to eq(1)
          expect(doc_second_lvl.data['ancestors']).to eq(["/docs/root/"])
          expect(doc_second_lvl.data['children'].size).to eq(1)
          expect(doc_second_lvl.data['children']).to eq(["/docs/second-level.third-level/"])
        end

        it "third-lvl ('ancestors': 2; 'children': 0; w/ urls)" do
          expect(doc_third_lvl.data['ancestors'].size).to eq(2)
          expect(doc_third_lvl.data['ancestors']).to eq(["/docs/root/", "/docs/second-level/"])
          expect(doc_third_lvl.data['children'].size).to eq(0)
        end

      end

    end

    context "when tree.path level does not exist" do

      it "parent of missing level inserts namespace instead of url in 'children' for missing levels" do
        expect(doc_root.data['children']).to include("root.blank")
      end

      it "child of missing level inserts namespace instead of url in 'ancestors' for missing levels" do
        expect(doc_missing_lvl.data['ancestors'].size).to eq(2)
        expect(doc_missing_lvl.data['ancestors']).to include("root.blank")
      end

    end

  end

end
