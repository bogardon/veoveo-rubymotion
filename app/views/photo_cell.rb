class PhotoCell < UICollectionViewCell
  attr_accessor :photo

  def initWithFrame(frame)
    super

    self.backgroundView = "middle_row.png".uiimage.center_stretch.uiimageview

    horizontal = UIView.alloc.initWithFrame [[1, 0], [self.contentView.frame.size.width - 2, 1]]
    horizontal.backgroundColor = [200, 200, 200].uicolor
    self.contentView.addSubview(horizontal)

    @photo = UIImageView.alloc.initWithFrame [[1,1],[self.contentView.frame.size.width-2, self.contentView.frame.size.height-1]]
    @photo.contentMode = UIViewContentModeScaleAspectFill
    @photo.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight
    self.contentView.addSubview(@photo)

    self
  end
end
