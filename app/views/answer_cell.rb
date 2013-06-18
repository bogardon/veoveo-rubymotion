class AnswerCell < UICollectionViewCell
  attr_accessor :answer

  def initWithFrame(frame)
    super
    self.backgroundView = UIImageView.alloc.initWithImage("full_row.png".uiimage.stretchable([22,22,22,22]))

    @answer_image_view = AnswerImageView.alloc.initWithFrame([[1,1], [self.contentView.frame.size.width - 2, 148]])
    self.contentView.addSubview(@answer_image_view)

    horizontal = UIView.alloc.initWithFrame([[0, CGRectGetMaxY(@answer_image_view.frame)], [self.contentView.frame.size.width, 1]])
    horizontal.backgroundColor = [160,160,160].uicolor
    self.contentView.addSubview(horizontal)

    @user_image_view = UserImageView.alloc.initWithFrame([[6, CGRectGetMaxY(@answer_image_view.frame) + 6], [35, 35]])
    self.contentView.addSubview(@user_image_view)

    @label = UILabel.alloc.initWithFrame([[CGRectGetMaxX(@user_image_view.frame) + 5, CGRectGetMaxY(@answer_image_view.frame) + 6], [self.contentView.frame.size.width - 6*2 - 5 - 35, 40]])
    @label.font = UIFont.systemFontOfSize(11)
    @label.numberOfLines = 0
    @label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@label)

    self
  end

  def answer=(answer)
    @answer = answer

    @answer_image_view.set_image_from_url @answer.image_url_large

    @user_image_view.set_image_from_url @answer.user.avatar_url_thumb

    formatter = Time.cached_date_formatter("MMMM dd, YYYY")
    date_str = formatter.stringFromDate(@answer.created_at)

    @label.attributedText = (@answer.user.username.bold(11) + " found this on #{date_str}")
    @label.sizeToFit
  end
end
