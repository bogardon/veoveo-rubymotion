class Time
  def self.iso8601_with_timezone(time)
    cached_date_formatter("yyyy-MM-dd'T'HH:mm:ssZZZZZ").dateFromString(time)
  end
end
