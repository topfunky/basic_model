class Date
  def to_json(*a)
    {
      'json_class'   => self.class.name,
      'data'         => self.strftime("%Y/%m/%d")
    }.to_json(*a)
  end

  def self.json_create(o)
    parse(*o['data'])
  end
end
