# frozen_string_literal: true

require "jekyll-namespaces"
require "spec_helper"

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
        "testing"              => true,
        # "baseurl"              => "",
      )
    )
  end
  # let(:config_overrides)              { {} }
  let(:config_overrides)                { { "namespaces" => { "include" => ["docs"] } } }
  let(:site)                            { Jekyll::Site.new(config) }
  
  let(:doc_root)                        { find_by_title(site.collections["docs"].docs, "Root") }
  let(:doc_second_lvl)                  { find_by_title(site.collections["docs"].docs, "Root Second Level") }
  let(:doc_missing_lvl)                 { find_by_title(site.collections["docs"].docs, "Missing Level") }

  let(:graph_data)                      { static_graph_file_content() }
  let(:graph_generated_fpath)           { find_generated_file("/assets/graph-tree.json") }
  let(:graph_static_file)               { find_static_file("/assets/graph-tree.json") }
  let(:graph_root)                      { get_graph_root() }
  let(:graph_node)                      { get_graph_node() }
  let(:missing_graph_node)              { get_missing_graph_node() }

  # makes markdown tests work
  subject                               { described_class.new(site.config) }

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

  context "graph" do

    context "config" do

      context "when graph disabled in configs" do
        let(:config_overrides) { { "d3_graph_data" => { "enabled" => false }, "namespaces" => { "include" => ["docs"] } } }
        
        it "does not generate graph data" do
          expect { File.read("#{fixtures_dir("/assets/graph-tree.json")}") }.to raise_error(Errno::ENOENT)
          expect { File.read("#{site_dir("/assets/graph-tree.json")}") }.to raise_error(Errno::ENOENT)
        end

      end

      context "when graph assets location set" do
        let(:config_overrides) { { "d3_graph_data" => { "path" => "/custom_assets_path" }, "namespaces" => { "include" => ["docs"] } } }

        before(:context) do
          assets_path = File.join(fixtures_dir, "custom_assets_path")
          Dir.mkdir(assets_path)
        end

        after(:context) do
          # cleanup generated assets
          FileUtils.rm_rf(Dir["#{fixtures_dir("/custom_assets_path/graph-tree.json")}"])
          FileUtils.rm_rf(Dir["#{fixtures_dir("/custom_assets_path")}"])
        end

        it "writes graph file to custom location" do
          expect(find_generated_file("/custom_assets_path/graph-tree.json")).to eq(File.join(fixtures_dir, "/custom_assets_path/graph-tree.json"))
          expect(find_static_file("/custom_assets_path/graph-tree.json")).to be_a(Jekyll::StaticFile)
          expect(find_static_file("/custom_assets_path/graph-tree.json").relative_path).to eq"/custom_assets_path/graph-tree.json"
        end

      end

    end

    context "default behavior" do

      context "when tree.path levels exists" do

        it "generates graph data" do
          expect(graph_generated_fpath).to eq(File.join(fixtures_dir, "/assets/graph-tree.json"))
          expect(graph_static_file).to be_a(Jekyll::StaticFile)
          expect(graph_static_file.relative_path).not_to be(nil)
          expect(graph_data.class).to be(Hash)
        end

        context "root node" do

          it "has format: { nodes: [ {id: '', url: '', label: ''}, ... ] }" do
            expect(graph_node.keys).to include("id")
            expect(graph_node.keys).to include("url")
            expect(graph_node.keys).to include("label")
          end

          it "'children'" do
            expect(graph_root["children"].size).to eq(2)
            expect(graph_root["children"][0].keys).to eq(["id", "namespace", "label", "children", "url"])
          end

          it "'id's equal their url (since urls should be unique)" do
            expect(graph_root["id"]).to eq(graph_root["url"])
          end

          it "'label's equal their doc title" do
            expect(graph_root["label"]).to eq(doc_root.data["title"])
          end

          it "'namespace's equal their doc filename" do
            expect(graph_root["namespace"]).to eq(doc_root.basename_without_ext)
          end

          it "'url's equal their doc urls" do
            expect(graph_root["url"]).to eq(doc_root.url)
          end

        end

        context "non-root nodes are like the root except" do

          it "'namespace's equal their doc filename + 'root.' " do
            expect(graph_node["namespace"]).to eq("root." + doc_second_lvl.basename_without_ext)
          end

        end

      end

      context "when tree.path level does not exist" do

        context "parent of missing node" do

          it "has missing level as a child" do
            missing_node = graph_root["children"].find { |n| n["namespace"] == "root.blank" }
            expect(missing_node).not_to be(nil)
            expect(missing_node["namespace"]).to eq("root.blank")
          end

        end

        context "missing node" do
        
          it "has keys: [ 'id', 'label', 'namespace', and 'url' ]" do
            expect(missing_graph_node.keys).to include("id")
            expect(missing_graph_node.keys).to include("label")
            expect(missing_graph_node.keys).to include("namespace")
            expect(missing_graph_node.keys).to include("url")
          end

          it "'id's is an empty string" do
            expect(missing_graph_node["id"]).to eq("")
          end

          it "'label' equals the namespace of the missing level" do
            expect(missing_graph_node["label"]).to eq("blank")
          end

          it "'url' is an empty string" do
            expect(missing_graph_node["url"]).to eq("")
          end

        end
      
      end

    end

  end

end