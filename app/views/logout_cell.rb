class LogoutCell < UICollectionViewCell

  attr_accessor :label

  def initWithFrame(frame)
    super
    self.backgroundView = UIImageView.alloc.initWithImage "primary_button.png".uiimage.stretchable([22,22,21,21])
    self.selectedBackgroundView = UIImageView.alloc.initWithImage "primarybutton_down.png".uiimage.stretchable([22,22,21,21])

    @label = UILabel.alloc.initWithFrame([[0,12],[306,20]])
    @label.text = "Logout"
    @label.textAlignment = NSTextAlignmentCenter
    @label.font = UIFont.boldSystemFontOfSize(20)
    @label.textColor = UIColor.whiteColor
    @label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@label)

    self
  end
end
