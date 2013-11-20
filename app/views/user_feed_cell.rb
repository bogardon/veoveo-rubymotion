class UserFeedCell < FeedCell
  attr_accessor :answer
  def initWithFrame(frame)
    super

    @icon = UIImageView.alloc.initWithImage "location_icon.png".uiimage
    @icon.frame = [[15, 10], @icon.frame.size]
    self.contentView.addSubview(@icon)

    @label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(@icon.frame)+10, 10], [self.contentView.frame.size.width - 5 - CGRectGetMaxX(@icon.frame) - 10, self.contentView.frame.size.height - 10 - 10]]
    @label.font = UIFont.systemFontOfSize(11)
    @label.autoresizingMask = UIViewAutoresizingFlexibleHeight
    @label.numberOfLines = 0
    @label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@label)

    @right_icon = "1st_icon_gray.png".uiimageview
    self.contentView.addSubview(@right_icon)

    self
  end

  def layoutSubviews
    super
    @icon.frame = [[15, ((self.contentView.frame.size.height-@icon.frame.size.height)/2).floor], @icon.frame.size]
    @right_icon.frame = [[self.contentView.frame.size.width-15-@right_icon.frame.size.width, ((self.contentView.frame.size.height-@right_icon.frame.size.height)/2).floor], @right_icon.frame.size]
  end

  def answer=(answer)
    @answer = answer
    @right_icon.hidden = @answer.spot.user_id != answer.user_id
    attr_text = @answer.spot.hint.bold(12) + "\n" + @answer.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)

    @label.attributedText = attr_text
  end

  def self.size_for_answer(answer)
    attr_text = answer.spot.hint.bold(12) + "\n" + answer.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)
    size = attr_text.boundingRectWithSize([306-10-13-10-5, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading, context:nil).size
    [306, size.height.ceil + 10 + 10]
  end
end
