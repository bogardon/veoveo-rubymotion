class SpotAnnotationView < MKAnnotationView
  include BW::KVO

  attr_accessor :left
  attr_accessor :label
  attr_accessor :right
  attr_accessor :callout

  def initWithAnnotation(annotation, reuseIdentifier:reuseIdentifier)
    super
    self.centerOffset = [0, -18]
    self.canShowCallout = false

    arrow = "arrow.png".uiimage
    @right = UIButton.alloc.initWithFrame [[168,5], [32, 32]]
    @right.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    @right.setImage(arrow, forState:UIControlStateNormal)
#    self.rightCalloutAccessoryView = right

    @left = UIButton.alloc.initWithFrame [[5,5], [32, 32]]
    @left.autoresizingMask = UIViewAutoresizingFlexibleRightMargin
    @user_image_view = UserImageView.alloc.initWithFrame [[0,0], [32,32]]
    @left.addSubview(@user_image_view)
#    self.leftCalloutAccessoryView = left

    spot = self.annotation

    observe(spot, :unlocked) do |old_value, new_value|
      update_image
    end

    @callout_view = "callout_bg.png".uiimage.center_stretch.uiimageview
    @callout_view.setUserInteractionEnabled(true)
    @callout_view.hidden = true
    self.addSubview(@callout_view)

    @label = UILabel.alloc.initWithFrame([[42,0],[121, @callout_view.frame.size.height]])
    @label.autoresizingMask = UIViewAutoresizingFlexibleWidth
    @label.backgroundColor = UIColor.clearColor
    @label.textColor = UIColor.whiteColor
    @label.numberOfLines = 2
    @label.font = UIFont.boldSystemFontOfSize(14)


    @callout = UIButton.alloc.initWithFrame(@callout_view.bounds)
    @callout.autoresizingMask = UIViewAutoresizingFlexibleWidth

    @callout_view.addSubview(@label)
    @callout_view.addSubview(@callout)
    @callout_view.addSubview(@left)
    @callout_view.addSubview(@right)

    self
  end

  def hitTest(point, withEvent:event)
    if CGRectContainsPoint(@callout_view.frame, point)
      new_point = self.convertPoint(point, toView:@callout_view)
      return @callout_view.hitTest(new_point, withEvent:event)
    end
    super
  end

  def pointInside(point, withEvent:event)

    if CGRectContainsPoint(@callout_view.frame, point)
      return true
    end
    super
  end


  def dealloc
    if self.annotation
      unobserve(self.annotation, :unlocked)
    end
    super
  end

  def setAnnotation(annotation)
    if self.annotation
      unobserve(self.annotation, :unlocked)
    end
    super
    if self.annotation
      observe(self.annotation, :unlocked) do |old_value, new_value|
        update_image
      end
    end
  end

  def setSelected(selected, animated:animated)
    super
    update_image

    @callout_view.center = [(self.frame.size.width/2).floor, -30]
    superview = self.superview.superview.superview.superview
    frame = self.convertRect(@callout_view.frame, toView:superview)
    unless CGRectContainsRect(superview.bounds, frame)
      x_origin_delta = if frame.origin.x < 0
        -frame.origin.x+5
      elsif frame.origin.x > 320 - @callout_view.frame.size.width
        320 - frame.origin.x - frame.size.width - 5
      else
        0
      end

      y_origin_delta = if frame.origin.y < 0
        -frame.origin.y + 5
      else
        0
      end
      @callout_view.frame = [[@callout_view.frame.origin.x + x_origin_delta, @callout_view.frame.origin.y + y_origin_delta], @callout_view.frame.size]

    end
    @callout_view.hidden = !selected
  end

  def update_image
    spot = self.annotation
    return unless spot
    #size = spot.hint.sizeWithFont(@label.font, constrainedToSize:[CGFLOAT_MAX,@label.size.height])

    @label.text = spot.hint
    size = @label.sizeThatFits([226,@label.size.height])
    @callout_view.frame = [@callout_view.frame.origin,[size.width.ceil + 5 + 32 + 5 + 5 + 32 + 5, @callout_view.frame.size.height]]

    state = spot.unlocked ? "found_pin" : "unfound_pin"
    selected = self.isSelected ? "_selected.png" : ".png"
    self.image = (state+selected).uiimage

    @user_image_view.set_image_from_url spot.user.avatar_url_thumb if spot.user
  end

end
