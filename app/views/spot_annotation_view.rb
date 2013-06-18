class SpotAnnotationView < MKAnnotationView
  include BW::KVO
  attr_accessor :spot
  def initWithAnnotation(annotation, reuseIdentifier:reuseIdentifier)
    super
    self.centerOffset = [0, -18]
    self.canShowCallout = true
    self.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonTypeDetailDisclosure)
    update_image

    spot = self.annotation

    observe(spot, :unlocked) do |old_value, new_value|
      update_image
    end

    self
  end

  def setSelected(selected, animated:animated)
    super
    update_image
  end

  def update_image
    spot = self.annotation
    state = spot.unlocked ? "found_pin" : "unfound_pin"
    selected = self.isSelected ? "_selected.png" : ".png"
    self.image = (state+selected).uiimage
  end

end
