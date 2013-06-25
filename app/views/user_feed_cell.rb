class UserFeedCell < FeedCell
  attr_accessor :answer
  def initWithFrame(frame)
    super

    @icon = UIImageView.alloc.initWithImage "location_icon.png".uiimage
    @icon.frame = [[15, 10], @icon.frame.size]
    self.contentView.addSubview(@icon)

    @spot_label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(@icon.frame)+10, 10], [self.contentView.frame.size.width - 5 - CGRectGetMaxX(@icon.frame) - 10, 15]]
    @spot_label.backgroundColor = UIColor.clearColor
    @spot_label.font = UIFont.boldSystemFontOfSize(12)
    self.contentView.addSubview(@spot_label)

    @date_label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(@icon.frame)+10, 10 + 15], @spot_label.size]
    @date_label.backgroundColor = UIColor.clearColor
    @date_label.font = UIFont.systemFontOfSize 11
    self.contentView.addSubview(@date_label)

    self
  end

  def answer=(answer)
    @answer = answer

    @spot_label.text = @answer.spot.hint
    @date_label.text = @answer.humanized_date

  end

end
