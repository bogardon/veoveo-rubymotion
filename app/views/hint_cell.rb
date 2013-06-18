class HintCell < UICollectionViewCell

  attr_accessor :form

  def initWithFrame(frame)
    super

    self.backgroundView = UIImageView.alloc.initWithImage "row_top.png".uiimage.stretchable([22,22,22,22])

    @form = FormTextField.alloc.init
    @form.frame = CGRectInset(self.contentView.frame, 9, 9)
    @form.label.text = "I FOUND:"
    self.contentView.addSubview(@form)

    self
  end

end
