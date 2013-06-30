class AnswerFeedCell < FeedCell
  attr_accessor :answer
  attr_accessor :image_button
  def initWithFrame(frame)
    super
    @user_image_view = UserImageView.alloc.initWithFrame [[5,5], [35, 35]]
    self.contentView.addSubview(@user_image_view)

    @image_button = UIButton.alloc.initWithFrame @user_image_view.frame
    self.contentView.addSubview(@image_button)

    @label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(@user_image_view.frame)+10, 5], [self.contentView.frame.size.width - @user_image_view.frame.size.width - 5 - 5-  5, self.contentView.frame.size.height - 10]]
    @label.numberOfLines = 3
    @label.backgroundColor = UIColor.clearColor
    @label.font = UIFont.systemFontOfSize 12
    self.contentView.addSubview(@label)


    self
  end

  def answer=(answer)
    @answer = answer

    @user_image_view.set_image_from_url @answer.user.avatar_url_thumb
    @label.attributedText = @answer.user.username.bold(12) + " found:\n" + @answer.spot.hint.bold(12) + "\n" + @answer.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)
  end
end
