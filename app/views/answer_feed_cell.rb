class AnswerFeedCell < FeedCell
  attr_accessor :answer
  attr_accessor :image_button
  def initWithFrame(frame)
    super
    @user_image_view = UserImageView.alloc.initWithFrame [[5,5], [35, 35]]
    self.contentView.addSubview(@user_image_view)

    @image_button = UIButton.alloc.initWithFrame @user_image_view.frame
    self.contentView.addSubview(@image_button)

    @label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(@user_image_view.frame)+10, 5], [self.contentView.frame.size.width - @user_image_view.frame.size.width - 5 - 5 - 10, self.contentView.frame.size.height - 10]]
    @label.autoresizingMask = UIViewAutoresizingFlexibleHeight
    @label.numberOfLines = 3
    @label.backgroundColor = UIColor.clearColor
    @label.font = UIFont.systemFontOfSize 12
    self.contentView.addSubview(@label)


    self
  end

  def answer=(answer)
    @answer = answer

    @user_image_view.set_image_from_url @answer.user.avatar_url_thumb

    verb = @answer.user.id == @answer.spot.user_id ? "discovered" : "found"

    @label.attributedText = @answer.user.username.bold(12) + " #{verb}:\n" + @answer.spot.hint.bold(12) + "\n" + @answer.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)
  end

  def self.size_for_answer(answer)
    verb = answer.user.id == answer.spot.user_id ? "discovered" : "found"
    attr_string = answer.user.username.bold(12) + " #{verb}:\n" + answer.spot.hint.bold(12) + "\n" + answer.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)
    #     CGSize size = [attrStr boundingRectWithSize:CGSizeMake(248, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;

    size = attr_string.boundingRectWithSize([306-5-35-10-5, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading, context:nil).size
    [306, size.height.ceil + 10]
  end
end
