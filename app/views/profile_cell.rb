class ProfileCell < UICollectionViewCell

  attr_accessor :user

  def initWithFrame(frame)
    super

    self.backgroundView = UIImageView.alloc.initWithImage "full_row.png".uiimage.center_stretch

    @user_image_view = ImageView.alloc.initWithFrame [[5,5], [80, 80]]
    self.contentView.addSubview(@user_image_view)

    vertical = UIView.alloc.initWithFrame [[90,0],[1, self.contentView.frame.size.height]]
    vertical.backgroundColor = [160,160,160].uicolor
    self.contentView.addSubview(vertical)

    horizontal = UIView.alloc.initWithFrame([[91, (self.contentView.frame.size.height/2).floor], [self.contentView.frame.size.width-91, 1]])
    horizontal.backgroundColor = vertical.backgroundColor
    self.contentView.addSubview(horizontal)

    self
  end

  def user=(user)
    @user = user

    @user_image_view.set_image_from_url @user.avatar_url_full

  end
end
