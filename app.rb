require "sinatra/base"
require "json"
require_relative "lib/models"

class App < Sinatra::Base
  before do
    content_type :json
  end

  helpers do
    def json_body
      raw = request.body.read
      data = JSON.parse(raw, symbolize_names: true)
      halt 400, { error: "Gövde bir JSON nesnesi olmalı" }.to_json unless data.is_a?(Hash)
      data
    rescue JSON::ParserError
      halt 400, { error: "Geçersiz JSON" }.to_json
    end

    def find_note!
      Note[params[:id].to_i] || halt(404, { error: "Not bulunamadı" }.to_json)
    end

    def find_link!
      Link.first(code: params[:code]) || halt(404, { error: "Link bulunamadı" }.to_json)
    end

    def save!(record)
      record.save
    rescue Sequel::ValidationFailed => e
      halt 422, { errors: e.errors.full_messages }.to_json
    end

    # Link çıktısına tam kısa adresi ekler
    def link_json(link)
      link.to_api.merge(short_url: "#{request.base_url}/#{link.code}")
    end
  end

  get "/health" do
    { status: "ok" }.to_json
  end

  get "/" do
    send_file File.join(settings.public_folder, "index.html"), type: :html
  end

  # ---------- Notlar ----------

  get "/notes" do
    Note.order(Sequel.desc(:created_at)).all.map(&:to_api).to_json
  end

  get "/notes/:id" do
    find_note!.to_api.to_json
  end

  post "/notes" do
    note = Note.new
    note.set_fields(json_body, [:title, :body], missing: :skip)
    save!(note)
    status 201
    note.to_api.to_json
  end

  put "/notes/:id" do
    note = find_note!
    note.set_fields(json_body, [:title, :body], missing: :skip)
    save!(note)
    note.to_api.to_json
  end

  delete "/notes/:id" do
    find_note!.destroy
    status 204
  end

  # ---------- Linkler ----------

  # Tüm linkleri listele
  get "/links" do
    Link.order(Sequel.desc(:created_at)).all.map { |l| link_json(l) }.to_json
  end

  # Link bilgisi ve tıklama sayısı
  get "/links/:code" do
    link_json(find_link!).to_json
  end

  # Yeni kısa link oluştur
  post "/links" do
    link = Link.new
    link.set_fields(json_body, [:url, :note_id], missing: :skip)
    save!(link)
    status 201
    link_json(link).to_json
  end

  # Linki sil
  delete "/links/:code" do
    find_link!.destroy
    status 204
  end

  # ---------- Yönlendirme (en sonda kalmalı) ----------

  get %r{/([A-Za-z0-9]{6})} do |code|
    link = Link.first(code: code)
    halt 404, { error: "Link bulunamadı" }.to_json unless link

    link.register_click!
    redirect link.url, 302
  end

  not_found do
    content_type :json
    { error: "Sayfa bulunamadı" }.to_json
  end
end