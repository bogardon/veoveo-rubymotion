class SpotProxy
  attr_accessor :spot

  def coordinate
    CLLocationCoordinate2DMake(self.spot.latitude, self.spot.longitude)
  end

  def title
    self.spot.hint
  end

  def isEqual(other)
    return false unless other.isKindOfClass(self.class)
    return self.spot == other.spot
  end

  def hash
    return self.spot.hash
  end

end
