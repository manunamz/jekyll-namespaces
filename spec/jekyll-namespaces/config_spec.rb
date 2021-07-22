# frozen_string_literal: true

require "jekyll-namespaces"

RSpec.describe JekyllNamespaces do
  it "has a version number" do
    expect(JekyllNamespaces::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end


# RSpec.describe(JekyllNamespaces) do
#   it "has a version number" do
#     expect(JekyllNamespaces::VERSION).not_to be nil
#   end

#   it "does something useful" do
#     expect(false).to eq(true)
#   end
# end

# RSpec.describe(JekyllNamespaces::Generator) do
#   it "does something useful" do
#     expect(false).to eq(true)
#   end
# end
