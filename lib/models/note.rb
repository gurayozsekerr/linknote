class Note < Sequel::Model
  one_to_many :links

  def validate
    super
    validates_presence :title
    validates_max_length 200, :title
  end

  def to_api
    {
      id: id,
      title: title,
      body: body,
      links: links.map(&:to_api),
      created_at: created_at,
      updated_at: updated_at
    }
  end
end