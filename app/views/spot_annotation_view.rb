class SpotAnnotationView < MKAnnotationView
  attr_accessor :spot
  def initWithAnnotation(annotation, reuseIdentifier:reuseIdentifier)
    super
    self.centerOffset = [0, -18]
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonTypeDetailDisclosure)
    update_image
    self
  end

  def setSelected(selected, animated:animated)
    super
    update_image

  end

  def update_image
    spot = self.annotation.spot
    state = spot.unlocked ? "found_pin" : "unfound_pin"
    selected = self.isSelected ? "_selected.png" : ""
    self.image = (state+selected).uiimage
  end

end
