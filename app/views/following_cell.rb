class FollowingCell < FeedCell
  attr_accessor :user

  def initWithFrame(frame)
    super

    @user_image_view = UserImageView.alloc.initWithFrame([[5, 5], [35, 35]])
    self.contentView.addSubview(@user_image_view)

    @username_label = UILabel.alloc.initWithFrame([[CGRectGetMaxX(@user_image_view.frame)+5, 5], [self.contentView.frame.size.width - CGRectGetMaxX(@user_image_view.frame)-5-5, 35]])
    @username_label.backgroundColor = UIColor.clearColor
    @username_label.font = UIFont.boldSystemFontOfSize 14
    self.contentView.addSubview(@username_label)

    self
  end

  def user=(user)
    @user = user
    @user_image_view.set_image_from_url @user.avatar_url_thumb
    @username_label.text = @user.username
  end
end
