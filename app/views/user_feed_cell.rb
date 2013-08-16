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

    self
  end

  def answer=(answer)
    @answer = answer

    attr_text = @answer.spot.hint.bold(12) + "\n" + @answer.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)

    @label.attributedText = attr_text
  end

  def self.size_for_answer(answer)
    attr_text = answer.spot.hint.bold(12) + "\n" + answer.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)
    size = attr_text.boundingRectWithSize([306-10-13-10-5, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading, context:nil).size
    [306, size.height.ceil + 10 + 10]
  end
end
