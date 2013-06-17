class SocialCell < UICollectionViewCell

  attr_accessor :user_image_view
  attr_accessor :label

  def initWithFrame(frame)
    super
        full = "full_row.png".uiimage.stretchable([22,22,22,22])
        self.backgroundView = UIImageView.alloc.initWithImage(full)

        @user_image_view = UserImageView.alloc.initWithFrame([[7,6],[35,35]])
        self.contentView.addSubview(@user_image_view)

        @label = UILabel.alloc.initWithFrame([[CGRectGetMaxX(@user_image_view.frame)+5,6],[self.contentView.frame.size.width - 35 - 5 - 5 - 5, self.contentView.frame.size.height - 12]])
        @label.backgroundColor = UIColor.clearColor
        @label.font = UIFont.systemFontOfSize(11)
        @label.numberOfLines = 0
        self.contentView.addSubview(@label)
    self
  end
end
