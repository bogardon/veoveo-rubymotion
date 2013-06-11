class SpotAnnotation < MKAnnotationView
  attr_accessor :spot
  def initWithAnnotation(annotation, reuseIdentifier:reuseIdentifier)
    super

    self.centerOffset = [0, -18]
    self.image = "unfound_pin.png".uiimage
    self.canShowCallout = true
    self
  end

end
