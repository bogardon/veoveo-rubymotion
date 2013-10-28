class ProfileCell < UICollectionViewCell

  attr_accessor :user
  attr_accessor :image_button
  attr_accessor :following_button

  def initWithFrame(frame)
    super

    self.backgroundView = UIImageView.alloc.initWithImage "full_row.png".uiimage.center_stretch

    @user_image_view = ImageView.alloc.initWithFrame [[5,5], [80, 80]]
    self.contentView.addSubview(@user_image_view)

    @image_button = UIButton.alloc.initWithFrame @user_image_view.frame
    self.contentView.addSubview(@image_button)

    @image_button.setTitleColor(UIColor.blackColor, forState:UIControlStateNormal)
    @image_button.titleLabel.font = UIFont.boldSystemFontOfSize(14)
    @image_button.titleLabel.numberOfLines = 0
    @image_button.titleEdgeInsets = [0,5,0,5]

    vertical = UIView.alloc.initWithFrame [[90,0],[1, self.contentView.frame.size.height]]
    vertical.backgroundColor = [160,160,160].uicolor
    self.contentView.addSubview(vertical)

    horizontal = UIView.alloc.initWithFrame([[91, (self.contentView.frame.size.height/2).floor], [self.contentView.frame.size.width-91, 1]])
    horizontal.backgroundColor = vertical.backgroundColor
    self.contentView.addSubview(horizontal)

    @username_label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(vertical.frame) + 20, 0], [self.contentView.frame.size.width - 100, (self.contentView.frame.size.height/2).floor]]
    @username_label.font = UIFont.boldSystemFontOfSize 16
    @username_label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@username_label)

    @following_button = UIButton.alloc.initWithFrame([[CGRectGetMaxX(vertical.frame) + 20, CGRectGetMaxY(horizontal.frame)], [self.contentView.frame.size.width - 100, (self.contentView.frame.size.height/2).floor]])
    @following_button.setTitle("Following", forState:UIControlStateNormal)
    @following_button.titleLabel.font = UIFont.boldSystemFontOfSize 16
    @following_button.setTitleColor(@username_label.textColor, forState:UIControlStateNormal)
    @following_button.setImage("arrow.png".uiimage, forState:UIControlStateNormal)
    @following_button.setTitleEdgeInsets([0,-100,0,45])
    @following_button.setImageEdgeInsets([0,110,0,-100])
    self.contentView.addSubview(@following_button)

    self
  end

  def user=(user)
    @user = user

    @user_image_view.set_image_from_url @user.avatar_url_full
    @username_label.text = @user.username

    title = @user.is_current? && @user.avatar_url_full && !@user.avatar_url_full.scheme ? "Tap here to change" : nil
    @image_button.setTitle(title, forState:UIControlStateNormal)
  end
end
