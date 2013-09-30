class NotificationCell < FeedCell
  attr_accessor :label
  attr_accessor :check_mark
  def initWithFrame(frame)
    super
    @label = UILabel.alloc.initWithFrame([[10,15],[self.contentView.frame.size.width - 20, self.contentView.frame.size.height - 30]])
    @label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@label)

    @check_mark = "check_mark.png".uiimageview
    @check_mark.frame = [[self.contentView.frame.size.width - 10 - @check_mark.frame.size.width, (self.contentView.frame.size.height/2 - @check_mark.frame.size.height/2).floor], @check_mark.frame.size]
    self.contentView.addSubview(@check_mark)
    self
  end

  def setSelected(selected)
    super
    @check_mark.hidden = !selected
  end
end

