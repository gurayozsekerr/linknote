require "spec_helper"

RSpec.describe "Ana sayfa" do
  it "HTML olarak döner" do
    get "/"

    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to include("text/html")
  end
end