class MapCell < UICollectionViewCell

  attr_accessor :map_view
  attr_accessor :label

  def initWithFrame(frame)
    super


    bot_bg = UIImageView.alloc.initWithImage "bottom_row.png".uiimage.stretchable([22,22,22,22])
    bot_bg.frame = [[0, 45], [self.contentView.frame.size.width, self.contentView.frame.size.height-45]]
    self.contentView.addSubview(bot_bg)

    @map_view = MKMapView.alloc.initWithFrame([[1,45],[self.contentView.frame.size.width-2, self.contentView.frame.size.height - 45 - 1]])
    @map_view.scrollEnabled = false
    @map_view.zoomEnabled = false
    @map_view.showsUserLocation = true

    # round bottom
    mask_layer = CAShapeLayer.layer
    mask_layer.frame = @map_view.layer.bounds
    path = UIBezierPath.bezierPathWithRoundedRect(mask_layer.bounds, byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight, cornerRadii:[3,3])
    mask_layer.path = path.CGPath
    @map_view.layer.mask = mask_layer
    self.contentView.addSubview(@map_view)

    top_bg = UIImageView.alloc.initWithImage "find_header.png".uiimage.stretchable([22,22,22,22])
    top_bg.frame = [[0,0],[self.contentView.frame.size.width, 45]]
    self.contentView.addSubview(top_bg)

    @label = UILabel.alloc.initWithFrame(CGRectInset(top_bg.frame, 1, 1))
    @label.backgroundColor = UIColor.clearColor
    @label.numberOfLines = 2
    @label.textAlignment = NSTextAlignmentCenter
    @label.font = UIFont.boldSystemFontOfSize(16)
    @label.textColor = BubbleWrap.rgb_color(51,51,51)
    self.contentView.addSubview(@label)

    self
  end

end
