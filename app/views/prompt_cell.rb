class PromptCell < UICollectionViewCell

  attr_reader :label

  def initWithFrame(frame)
    super
    self.backgroundView = "row_top.png".uiimage.center_stretch.uiimageview
    @label = UILabel.alloc.initWithFrame([[0,10],[self.contentView.frame.size.width, 30]])
    @label.font = UIFont.boldSystemFontOfSize(14)
    @label.textAlignment = NSTextAlignmentCenter
    @label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@label)
    self
  end
end
