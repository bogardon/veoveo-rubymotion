class SpotAnnotationView < MKAnnotationView
  include BW::KVO
  attr_accessor :spot
  def initWithAnnotation(annotation, reuseIdentifier:reuseIdentifier)
    super
    self.centerOffset = [0, -18]
    self.canShowCallout = true

    arrow = "arrow.png".uiimage
    right = UIButton.alloc.initWithFrame [[0,0], [32, 32]]
    right.setImage(arrow, forState:UIControlStateNormal)
    self.rightCalloutAccessoryView = right

    left = UIButton.alloc.initWithFrame [[0,0], [32, 32]]
    @user_image_view = UserImageView.alloc.initWithFrame [[0,0], [32,32]]
    left.addSubview(@user_image_view)
    self.leftCalloutAccessoryView = left

    spot = self.annotation

    observe(spot, :unlocked) do |old_value, new_value|
      update_image
    end

    self
  end

  def dealloc
    if self.annotation
      unobserve(spot, :unlocked)
    end
    super
  end

  def setAnnotation(annotation)
    if self.annotation
      unobserve(spot, :unlocked)
    end
    super
    if self.annotation
      observe(spot, :unlocked) do |old_value, new_value|
        update_image
      end
    end
  end

  def setSelected(selected, animated:animated)
    super
    update_image
  end

  def update_image
    spot = self.annotation
    return unless spot
    state = spot.unlocked ? "found_pin" : "unfound_pin"
    selected = self.isSelected ? "_selected.png" : ".png"
    self.image = (state+selected).uiimage

    @user_image_view.set_image_from_url spot.user.avatar_url_thumb if spot.user
  end

end
