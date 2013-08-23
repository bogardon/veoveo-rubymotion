class ConnectCell < UICollectionViewCell
  def initWithFrame(frame)
    super
    self.backgroundView = "middle_row.png".uiimage.center_stretch.uiimageview

    image_view = "fb_icon_on.png".uiimage.uiimageview
    image_view.frame = [[15, 6], image_view.size]
    self.contentView.addSubview(image_view)

    label = UILabel.alloc.initWithFrame [[CGRectGetMaxX(image_view.frame)+10,12], [200, 20]]
    label.text = Facebook.is_open? ? "Check Facebook" : "Connect with Facebook"
    label.font = UIFont.boldSystemFontOfSize(16)
    label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(label)

    arrow = "arrow.png".uiimage.uiimageview
    arrow.frame = [[self.contentView.frame.size.width - 15 - arrow.frame.size.width, (self.contentView.frame.size.height/2 - arrow.frame.size.height/2).floor], arrow.size]
    self.contentView.addSubview(arrow)
    self
  end
end
