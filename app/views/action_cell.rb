class ActionCell < UICollectionViewCell

  attr_accessor :label

  def initWithFrame(frame)
    super
    self.backgroundView = UIImageView.alloc.initWithImage "halfbutton.png".uiimage.stretchable([22,22,21,21])
    self.selectedBackgroundView = UIImageView.alloc.initWithImage "halfbutton_down.png".uiimage.stretchable([22,22,21,21])

    @label = UILabel.alloc.initWithFrame(CGRectInset(self.contentView.frame, 5, 5))
    @label.backgroundColor = UIColor.clearColor
    @label.font = UIFont.boldSystemFontOfSize(20)
    @label.textColor = UIColor.whiteColor
    @label.textAlignment = NSTextAlignmentCenter
    self.contentView.addSubview(@label)

    self
  end
end
