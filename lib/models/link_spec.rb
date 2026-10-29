require "spec_helper"

RSpec.describe Link do
  it "geçerli bir url ile oluşturulur ve 6 haneli kod alır" do
    link = Link.create(url: "https://github.com")

    expect(link.code).to match(/\A[A-Za-z0-9]{6}\z/)
    expect(link.clicks).to eq(0)
  end

  it "http veya https olmayan url'yi reddeder" do
    link = Link.new(url: "abc")

    expect(link.valid?).to be(false)
    expect(link.errors[:url]).not_to be_empty
  end

  it "url boşsa reddeder" do
    expect(Link.new.valid?).to be(false)
  end

  it "olmayan bir nota bağlanamaz" do
    link = Link.new(url: "https://github.com", note_id: 999)

    expect(link.valid?).to be(false)
    expect(link.errors[:note_id]).not_to be_empty
  end

  it "her link için farklı kod üretir" do
    codes = 20.times.map { Link.create(url: "https://ruby-lang.org").code }

    expect(codes.uniq.size).to eq(20)
  end

  it "tıklamayı sayar" do
    link = Link.create(url: "https://github.com")
    2.times { link.register_click! }

    expect(link.clicks).to eq(2)
  end
end