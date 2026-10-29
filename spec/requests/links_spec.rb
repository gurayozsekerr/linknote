require "spec_helper"

RSpec.describe "Links API" do
  describe "POST /links" do
    it "kısa link oluşturur" do
      post_json "/links", { url: "https://github.com" }

      expect(last_response.status).to eq(201)
      expect(json[:code]).to match(/\A[A-Za-z0-9]{6}\z/)
      expect(json[:short_url]).to end_with("/#{json[:code]}")
    end

    it "geçersiz url'yi 422 ile reddeder" do
      post_json "/links", { url: "abc" }

      expect(last_response.status).to eq(422)
    end

    it "olmayan nota bağlamayı 422 ile reddeder" do
      post_json "/links", { url: "https://github.com", note_id: 999 }

      expect(last_response.status).to eq(422)
    end

    it "dışarıdan gelen kodu ve tıklama sayısını yok sayar" do
      post_json "/links", { url: "https://github.com", code: "HACKED", clicks: 500 }

      expect(json[:code]).not_to eq("HACKED")
      expect(json[:clicks]).to eq(0)
    end
  end

  describe "GET /:code" do
    it "orijinal adrese yönlendirir" do
      link = Link.create(url: "https://github.com")

      get "/#{link.code}"

      expect(last_response.status).to eq(302)
      expect(last_response.headers["Location"]).to eq("https://github.com")
    end

    it "her yönlendirmede tıklama sayısını artırır" do
      link = Link.create(url: "https://github.com")

      2.times { get "/#{link.code}" }

      expect(link.refresh.clicks).to eq(2)
    end

    it "olmayan kod için 404 döner" do
      get "/zzzzzz"

      expect(last_response.status).to eq(404)
    end
  end

  describe "GET /links/:code" do
    it "link bilgisini getirir" do
      link = Link.create(url: "https://github.com")

      get "/links/#{link.code}"

      expect(json[:url]).to eq("https://github.com")
    end
  end

  describe "DELETE /links/:code" do
    it "linki siler" do
      link = Link.create(url: "https://github.com")

      delete "/links/#{link.code}"

      expect(last_response.status).to eq(204)
      expect(Link[link.id]).to be_nil
    end
  end

  describe "GET /health" do
    it "ok döner" do
      get "/health"

      expect(json[:status]).to eq("ok")
    end
  end
end