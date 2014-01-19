class OnboardCell < UICollectionViewCell

  attr_accessor :label
  attr_accessor :image_view

  def initWithFrame(frame)
    super

    @label = UILabel.alloc.initWithFrame [[35,30],[180,70]]
    @label.font = UIFont.boldSystemFontOfSize(20)
    @label.textColor = UIColor.colorWithRed(116.0/255.0, green:116.0/255.0, blue:116.0/255.0, alpha:1.0)
    @label.backgroundColor = UIColor.clearColor
    @label.textAlignment = NSTextAlignmentCenter
    @label.numberOfLines = 0
    self.contentView.addSubview(@label)

    @image_view = ImageView.alloc.initWithFrame [[0, 120], [250, 100]]
    @image_view.clipsToBounds = true
    @image_view.layer.borderColor = UIColor.lightGrayColor.CGColor
    self.contentView.addSubview(@image_view)
    self
  end
end
