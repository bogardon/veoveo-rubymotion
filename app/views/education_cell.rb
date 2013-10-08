class EducationCell < FeedCell
  attr_accessor :label
  attr_accessor :image_view
  def initWithFrame(frame)
    super
    @image_view = UIImageView.alloc.initWithFrame([[0,0],[50,50]])
    @image_view.contentMode = UIViewContentModeCenter
    self.contentView.addSubview(@image_view)

    @label = UILabel.alloc.initWithFrame([[50,0], [200, 50]])
    @label.backgroundColor = UIColor.clearColor
    self.contentView.addSubview(@label)
    self
  end
end
