class AnswerCell < UICollectionViewCell
  attr_accessor :answer
  attr_accessor :image_button
  attr_accessor :answer_image_view
  attr_accessor :first_image_view

  def initWithFrame(frame)
    super
    self.backgroundView = UIImageView.alloc.initWithImage("full_row.png".uiimage.stretchable([22,22,22,22]))

    @answer_image_view = AnswerImageView.alloc.initWithFrame([[1,1], [self.contentView.frame.size.width - 2, 148]])
    @answer_image_view.contentMode = UIViewContentModeScaleAspectFit
    self.contentView.addSubview(@answer_image_view)

    @image_button = UIButton.alloc.initWithFrame @answer_image_view.frame
    self.contentView.addSubview @image_button

    @first_image_view = UIImageView.alloc.initWithImage("1st_icon.png".uiimage)
    @first_image_view.frame = [[CGRectGetMaxX(@answer_image_view.frame) - 5 - @first_image_view.frame.size.width, CGRectGetMaxY(@answer_image_view.frame) - 5 - @first_image_view.frame.size.height], @first_image_view.frame.size]
    self.contentView.addSubview(@first_image_view)
    @first_image_view.setHidden(true)

    @user_image_view = UserImageView.alloc.initWithFrame([[6, CGRectGetMaxY(@answer_image_view.frame) + 6], [35, 35]])
    self.contentView.addSubview(@user_image_view)

    @label = UILabel.alloc.initWithFrame([[CGRectGetMaxX(@user_image_view.frame) + 5, CGRectGetMaxY(@answer_image_view.frame) + 17], [self.contentView.frame.size.width - 6*2 - 5 - 35, 12]])
    @label.font = UIFont.boldSystemFontOfSize(11)
    @label.numberOfLines = 0
    @label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@label)

    horizontal = UIView.alloc.initWithFrame([[1, CGRectGetMaxY(@user_image_view.frame) + 6], [self.contentView.frame.size.width-2, 0.5]])
    horizontal.backgroundColor = [200,200,200].uicolor
    self.contentView.addSubview(horizontal)

    @date_label = UILabel.alloc.initWithFrame([[6, CGRectGetMaxY(horizontal.frame) + 5.5], [self.contentView.frame.size.width - 12, 12]])
    @date_label.font = UIFont.systemFontOfSize(11)
    @date_label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@date_label)

    self
  end

  def answer=(answer)
    @answer = answer

    @answer_image_view.set_image_from_url @answer.image_url_large

    @user_image_view.set_image_from_url @answer.user.avatar_url_thumb if @answer.user

    @label.text = @answer.user.username

    @date_label.text = @answer.humanized_date

  end
end
