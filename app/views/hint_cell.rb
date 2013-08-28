class HintCell < UICollectionViewCell

  attr_accessor :form
  attr_accessor :map_view

  def initWithFrame(frame)
    super

    self.backgroundView = UIImageView.alloc.initWithImage "row_top.png".uiimage.stretchable([22,22,22,22])

    @form = FormTextField.alloc.init
    @form.frame = [[9, 9], [self.contentView.frame.size.width - 18, 26]]
    @form.label.text = "I FOUND:"
    self.contentView.addSubview(@form)

    horizontal = UIView.alloc.initWithFrame [[1, CGRectGetMaxY(@form.frame) + 5.5], [self.contentView.frame.size.width - 2, 0.5]]
    horizontal.backgroundColor = [200, 200, 200].uicolor
    self.contentView.addSubview(horizontal)

    @map_view = MKMapView.alloc.initWithFrame [[1, CGRectGetMaxY(horizontal.frame)], [self.contentView.frame.size.width - 2, 130]]
    @map_view.setScrollEnabled(false)
    @map_view.setZoomEnabled(false)
    self.contentView.addSubview(@map_view)

    self
  end

end
