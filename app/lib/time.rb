class Time
  def self.humanized_date_formatter
    return @humanized_date_formatter if @humanized_date_formatter
    @humanized_date_formatter = cached_date_formatter("MMMM dd, YYYY")
    @humanized_date_formatter.timeZone = NSTimeZone.localTimeZone
    @humanized_date_formatter
  end
end
