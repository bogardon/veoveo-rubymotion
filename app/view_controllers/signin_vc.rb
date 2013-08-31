class SignInVC < UIViewController
  include ViewControllerHelpers

  def loadView
    super
    background = "bg.png".uiimageview
    background.frame = self.view.bounds
    background.contentMode = UIViewContentModeScaleAspectFill
    background.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth
    self.view.addSubview(background)

    scroll_view = UIScrollView.alloc.initWithFrame(self.view.bounds)
    scroll_view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth
    scroll_view.alwaysBounceVertical = true
    self.view.addSubview(scroll_view)

    sign_in_container = "row_top.png".uiimage.stretchable([22,22,21,21]).uiimageview
    sign_in_container.setUserInteractionEnabled(true)
    sign_in_container.frame = [[7,7], [self.view.frame.size.width - 14, 71]]
    scroll_view.addSubview(sign_in_container)

    @username_field = FormTextField.alloc.initWithFrame([[15, 5], [276,25]])
    @username_field.label.text = "USERNAME:"
    @username_field.delegate = self
    @username_field.becomeFirstResponder
    @username_field.returnKeyType = UIReturnKeyNext
    sign_in_container.addSubview(@username_field)

    separator = "line.png".uiimageview
    separator.frame = [[0, 35], [306, 1]]
    sign_in_container.addSubview(separator)


    @password_field = FormTextField.alloc.initWithFrame([[15, 41], [276, 25]])
    @password_field.label.text = "PASSWORD:"
    @password_field.setSecureTextEntry(true)
    @password_field.delegate = self
    @password_field.returnKeyType = UIReturnKeyGo
    sign_in_container.addSubview(@password_field)
    @button =  UIButton.buttonWithType UIButtonTypeCustom
    @button.frame = [[7,78], [self.view.frame.size.width - 14, 44]]
    @button.titleLabel.font = UIFont.boldSystemFontOfSize(20)
    @button.titleLabel.shadowOffset = [0, 0.5]
    @button.setTitleShadowColor(UIColor.darkGrayColor, forState:UIControlStateNormal)
    @button.setBackgroundImage("halfbutton.png".uiimage.stretchable([22,22,21,21]), forState:UIControlStateNormal)
    @button.setBackgroundImage("halfbutton_down.png".uiimage.stretchable([22,22,21,21]), forState:UIControlStateHighlighted)
    @button.setTitle("Sign In", forState:UIControlStateNormal)
    @button.enabled = false
    scroll_view.addSubview(@button)

    scroll_view.contentSize = [320, CGRectGetMaxY(@button.frame) + 7]
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    @username_field.addTarget(self, action: :on_text_field_editing, forControlEvents:UIControlEventEditingChanged)
    @password_field.addTarget(self, action: :on_text_field_editing, forControlEvents:UIControlEventEditingChanged)
    @button.addTarget(self, action: :on_sign_in, forControlEvents:UIControlEventTouchUpInside)
  end

  def on_text_field_editing
    @button.enabled = form_valid?
  end

  def viewWillAppear(animated)
    super
    navigationController.setNavigationBarHidden(false, animated:true)
  end

  def on_sign_in
    return unless form_valid?
    @username_field.resignFirstResponder
    @password_field.resignFirstResponder
    self.show_hud
    User.sign_in username: @username_field.text, password: @password_field.text do |success|
      self.hide_hud success
      dismissViewControllerAnimated(true, completion:nil) if success
    end
  end

  def form_valid?
    @username_field.text && @password_field.text && @username_field.text.length > 0 && @password_field.text.length > 0
  end

  def textFieldShouldReturn(textfield)
    case textfield
    when @username_field
      @password_field.becomeFirstResponder
    when @password_field
      on_sign_in
    end
  end

end
