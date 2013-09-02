class LoadingShutter < UIView

  def start
    self.hidden = false
    rotate = CABasicAnimation.animationWithKeyPath "transform.rotation.z"
    rotate.fromValue = 0
    rotate.toValue = -2 * Math::PI
    rotate.repeatCount = Float::MAX
    rotate.duration = 2
    @loading_pin.layer.addAnimation(rotate, forKey:nil)
  end

  def stop
    self.hidden = true
    @loading_pin.layer.removeAllAnimations
  end

  def initWithFrame(frame)
    super

    self.backgroundColor = UIColor.clearColor

    @loading_shutter = UIImageView.alloc.initWithFrame([[0,0],frame.size])
    @loading_shutter.contentMode = UIViewContentModeCenter
    @loading_shutter.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight
    @loading_shutter.image = "loading_pin.png".uiimage
    self.addSubview(@loading_shutter)

    @loading_pin = "loading_shutter.png".uiimageview
    self.addSubview(@loading_pin)

    self
  end

  def layoutSubviews
    super

    @loading_pin.center = [(self.frame.size.width/2).floor, (self.frame.size.height/2).floor - 25]
  end

end
