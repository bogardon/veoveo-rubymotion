class SpotAnnotation
  attr_accessor :spot

  def initialize(spot)
    self.spot = spot
  end

  def coordinate
    CLLocationCoordinate2DMake(self.spot.latitude, self.spot.longitude)
  end

  def title
    self.spot.hint
  end

  def ==(other)
    return false unless other.is_a?(SpotAnnotation)
    self.spot == other.spot
  end
end
