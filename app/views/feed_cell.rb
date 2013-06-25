class FeedCell < UICollectionViewCell


  POSITION_FULL = 0
  POSITION_TOP = 1
  POSITION_MID = 2
  POSITION_BOT = 3

  def initWithFrame(frame)
    super

    @separator = "line.png".uiimage.uiimageview
    @separator.frame = [[0, self.frame.size.height - 1], [self.frame.size.width , 1]]
    @separator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin
    self.addSubview @separator

    self
  end

  def position=(position)
    @@bg_images ||=
      {
        POSITION_FULL => "full_row.png".uiimage.center_stretch,
        POSITION_TOP => "row_top.png".uiimage.center_stretch,
        POSITION_MID => "middle_row.png".uiimage.center_stretch,
        POSITION_BOT => "bottom_row.png".uiimage.center_stretch
      }
    image = @@bg_images[position]
    self.backgroundView = UIImageView.alloc.initWithImage image
    @separator.hidden = position == POSITION_FULL || position == POSITION_BOT
  end

end
