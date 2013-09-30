class NotificationHeaderCell < FeedCell
  attr_accessor :label
  def initWithFrame(frame)
    super
    @label = UILabel.alloc.initWithFrame([[10, 10], [self.contentView.frame.size.width - 20, self.contentView.frame.size.height - 20]])
    @label.font = UIFont.boldSystemFontOfSize(13)
    @label.backgroundColor = UIColor.clearColor
    @label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight
    self.contentView.addSubview(@label)
    self
  end

end
