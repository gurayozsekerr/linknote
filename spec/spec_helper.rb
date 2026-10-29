ENV["APP_ENV"] = "test"
ENV["DATABASE_PATH"] = ":memory:"

require "rack/test"
require "json"
require_relative "../app"

module ApiHelpers
  include Rack::Test::Methods

  def app
    App
  end

  def json
    JSON.parse(last_response.body, symbolize_names: true)
  end

  def post_json(path, payload)
    post path, payload.to_json, "CONTENT_TYPE" => "application/json"
  end

  def put_json(path, payload)
    put path, payload.to_json, "CONTENT_TYPE" => "application/json"
  end
end

RSpec.configure do |config|
  config.include ApiHelpers

  # Her testten önce tabloları temizle
  config.before(:each) do
    DB[:links].delete
    DB[:notes].delete
  end
end