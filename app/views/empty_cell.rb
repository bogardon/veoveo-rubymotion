class EmptyCell < UICollectionViewCell

  attr_accessor :label

  def initWithFrame(frame)
    super
    @label = UILabel.alloc.initWithFrame(self.contentView.bounds)
    @label.backgroundColor = UIColor.clearColor
    @label.font = UIFont.systemFontOfSize(14)
    @label.text = "None of your friends are on VeoVeo yet."
    @label.textAlignment = NSTextAlignmentCenter
    self.contentView.addSubview(@label)
    self
  end

end
