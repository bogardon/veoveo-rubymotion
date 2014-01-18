class FollowingCell < FeedCell
  attr_accessor :user
  attr_accessor :button

  def initWithFrame(frame)
    super

    @user_image_view = UserImageView.alloc.initWithFrame([[5, 5], [35, 35]])
    self.contentView.addSubview(@user_image_view)

    @username_label = UILabel.alloc.initWithFrame([[CGRectGetMaxX(@user_image_view.frame)+5, 5], [self.contentView.frame.size.width - CGRectGetMaxX(@user_image_view.frame)-5-5, 35]])
    @username_label.backgroundColor = UIColor.clearColor
    @username_label.font = UIFont.boldSystemFontOfSize 14
    self.contentView.addSubview(@username_label)

    @button = UIButton.buttonWithType UIButtonTypeCustom
    @button.frame = [[self.contentView.frame.size.width - 5 - 90, 5], [90, 35]]
    @button.setTitle("FOLLOWING", forState:UIControlStateSelected)
    @button.setTitle("FOLLOWING", forState:UIControlStateSelected|UIControlStateHighlighted)
    @button.setTitle("FOLLOW", forState:UIControlStateNormal)
    @button.setTitleColor([51,51,51].uicolor, forState:UIControlStateSelected)
    @button.setTitleColor([51,51,51].uicolor, forState:UIControlStateSelected|UIControlStateHighlighted)
    @button.setTitleColor(UIColor.whiteColor, forState:UIControlStateNormal)
    @button.titleLabel.font = UIFont.boldSystemFontOfSize 12
    @button.setBackgroundImage("primary_button.png".uiimage.center_stretch, forState:UIControlStateNormal)
    @button.setBackgroundImage("primarybutton_down.png".uiimage.center_stretch, forState:UIControlStateHighlighted)
    @button.setBackgroundImage("navbutton.png".uiimage.center_stretch, forState:UIControlStateSelected)
    @button.setBackgroundImage("navbutton_down.png".uiimage.center_stretch, forState:UIControlStateSelected|UIControlStateHighlighted)
    self.contentView.addSubview(@button)

    self
  end

  def user=(user)
    @user = user
    @user_image_view.set_image_from_url @user.avatar_url_thumb
    @username_label.text = @user.username
    @button.setSelected(@user.following)
  end
end
