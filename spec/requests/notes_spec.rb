require "spec_helper"

RSpec.describe "Notes API" do
  describe "POST /notes" do
    it "not oluşturur" do
      post_json "/notes", { title: "Merhaba", body: "İlk notum" }

      expect(last_response.status).to eq(201)
      expect(json[:title]).to eq("Merhaba")
      expect(json[:id]).to be_a(Integer)
    end

    it "başlıksız notu 422 ile reddeder" do
      post_json "/notes", { body: "başlıksız" }

      expect(last_response.status).to eq(422)
      expect(json[:errors]).not_to be_empty
    end

    it "bozuk JSON için 400 döner" do
      post "/notes", "{bozuk", "CONTENT_TYPE" => "application/json"

      expect(last_response.status).to eq(400)
    end

    it "dışarıdan gelen id değerini yok sayar" do
      post_json "/notes", { id: 999, title: "Test" }

      expect(json[:id]).not_to eq(999)
    end
  end

  describe "GET /notes" do
    it "notları listeler" do
      Note.create(title: "Bir")
      Note.create(title: "İki")

      get "/notes"

      expect(last_response.status).to eq(200)
      expect(json.size).to eq(2)
    end
  end

  describe "GET /notes/:id" do
    it "notu getirir" do
      note = Note.create(title: "Bir")

      get "/notes/#{note.id}"

      expect(json[:title]).to eq("Bir")
    end

    it "olmayan not için 404 döner" do
      get "/notes/12345"

      expect(last_response.status).to eq(404)
    end

    it "bağlı linkleri de gösterir" do
      note = Note.create(title: "Bir")
      Link.create(url: "https://github.com", note_id: note.id)

      get "/notes/#{note.id}"

      expect(json[:links].size).to eq(1)
    end
  end

  describe "PUT /notes/:id" do
    it "sadece gönderilen alanı günceller" do
      note = Note.create(title: "Eski", body: "Gövde")

      put_json "/notes/#{note.id}", { title: "Yeni" }

      expect(last_response.status).to eq(200)
      expect(json[:title]).to eq("Yeni")
      expect(json[:body]).to eq("Gövde")
    end
  end

  describe "DELETE /notes/:id" do
    it "notu siler" do
      note = Note.create(title: "Silinecek")

      delete "/notes/#{note.id}"

      expect(last_response.status).to eq(204)
      expect(Note[note.id]).to be_nil
    end

    it "notu silince bağlı link kalır ama bağı kopar" do
      note = Note.create(title: "Silinecek")
      link = Link.create(url: "https://github.com", note_id: note.id)

      delete "/notes/#{note.id}"

      expect(Link[link.id].note_id).to be_nil
    end
  end
end