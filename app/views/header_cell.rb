class HeaderCell < UICollectionViewCell
  def initWithFrame(frame)
    super
    @label = UILabel.alloc.initWithFrame([[10,10],[200,20]])
    @label.backgroundColor = UIColor.clearColor
    @label.font = UIFont.boldSystemFontOfSize 14
    @label.text = "Notifcations"
    self.contentView.addSubview(@label)
    self
  end
end
