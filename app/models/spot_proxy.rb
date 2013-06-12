class SpotProxy
  attr_accessor :spot

  def coordinate
    CLLocationCoordinate2DMake(self.spot.latitude, self.spot.longitude)
  end

  def title
    self.spot.hint
  end

end
