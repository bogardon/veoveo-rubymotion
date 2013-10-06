class NotificationCell < FeedCell
  attr_accessor :notification
  attr_accessor :image_button
  def initWithFrame(frame)
    super
    @user_image_view = UserImageView.alloc.initWithFrame [[5,5], [35, 35]]
    self.contentView.addSubview(@user_image_view)

    @image_button = UIButton.alloc.initWithFrame @user_image_view.frame
    self.contentView.addSubview(@image_button)

    @label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(@user_image_view.frame)+10, 5], [self.contentView.frame.size.width - @user_image_view.frame.size.width - 5 - 5 - 10, self.contentView.frame.size.height - 10]]
    @label.autoresizingMask = UIViewAutoresizingFlexibleHeight
    @label.numberOfLines = 0
    @label.backgroundColor = UIColor.clearColor
    @label.font = UIFont.systemFontOfSize 12
    self.contentView.addSubview(@label)

    self
  end

  def notification=(notification)
    @notification = notification

    @user_image_view.set_image_from_url @notification.src_user.avatar_url_thumb

    attributed_text = case @notification.notifiable_type
    when "Answer"
      @notification.src_user.username.bold(12) + " found " + @notification.answer.spot.hint.bold(12)
    when "Relationship"
      @notification.src_user.username.bold(12) + " followed you"
    end
    attributed_text += "\n".nsattributedstring + @notification.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)
    @label.attributedText = attributed_text
  end

  def self.size_for_notification(notification)
    attributed_text = case notification.notifiable_type
    when "Answer"
      notification.src_user.username.bold(12) + " found " + notification.answer.spot.hint.bold(12)
    when "Relationship"
      notification.src_user.username.bold(12) + " followed you"
    end
    attributed_text += "\n".nsattributedstring + notification.humanized_date.nsattributedstring.color(UIColor.lightGrayColor)

    size = attributed_text.boundingRectWithSize([306-5-35-10-5, Float::MAX], options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading, context:nil).size
    [306, [45, size.height.ceil + 10].max]
  end
end
