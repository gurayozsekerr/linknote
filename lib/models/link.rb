require "securerandom"
require "uri"

class Link < Sequel::Model
  many_to_one :note

  def self.generate_code
    loop do
      code = SecureRandom.alphanumeric(6)
      return code unless Link.where(code: code).count > 0
    end
  end

  def before_validation
    self.code ||= Link.generate_code
    super
  end

    def validate
    super
    validates_presence :url
    validate_url_format
    errors.add(:note_id, "ile eşleşen bir not bulunamadı") if note_id && Note[note_id].nil?
  end

  def register_click!
    Link.where(id: id).update(clicks: Sequel[:clicks] + 1)
    refresh
  end

  def to_api
    {
      id: id,
      code: code,
      url: url,
      clicks: clicks,
      note_id: note_id,
      created_at: created_at
    }
  end

  private

  def validate_url_format
    return if url.nil? || url.empty?

    uri = URI.parse(url)
    valid = uri.is_a?(URI::HTTP) && !uri.host.to_s.empty?
    errors.add(:url, "geçerli bir http veya https adresi olmalı") unless valid
  rescue URI::InvalidURIError
    errors.add(:url, "geçerli bir http veya https adresi olmalı")
  end
end