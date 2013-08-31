class SignUpVC < UIViewController
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

    sign_up_container = "row_top.png".uiimage.stretchable([22,22,21,21]).uiimageview
    sign_up_container.setUserInteractionEnabled(true)
    sign_up_container.frame = [[7,7], [self.view.frame.size.width - 14, 157]]
    scroll_view.addSubview(sign_up_container)

    prompt = UILabel.alloc.initWithFrame([[5,10], [sign_up_container.frame.size.width - 10, 30]])
    prompt.text = "1. Pick a Username & Password"
    prompt.font = UIFont.boldSystemFontOfSize(14)
    prompt.textAlignment = NSTextAlignmentCenter
    prompt.backgroundColor = UIColor.clearColor
    sign_up_container.addSubview(prompt)

    @username_field = FormTextField.alloc.initWithFrame([[15, 55], [276,25]])
    @username_field.label.text = "USERNAME:"
    @username_field.delegate = self
    @username_field.becomeFirstResponder
    @username_field.returnKeyType = UIReturnKeyNext
    sign_up_container.addSubview(@username_field)

    separator = "line.png".uiimageview
    separator.frame = [[0, 85], [306, 1]]
    sign_up_container.addSubview(separator)

    @password_field = FormTextField.alloc.initWithFrame([[15, 91], [276, 25]])
    @password_field.label.text = "PASSWORD:"
    @password_field.setSecureTextEntry(true)
    @password_field.delegate = self
    @password_field.returnKeyType = UIReturnKeyNext
    sign_up_container.addSubview(@password_field)

    separator = "line.png".uiimageview
    separator.frame = [[0, 121], [306, 1]]
    sign_up_container.addSubview(separator)

    @email_field = FormTextField.alloc.initWithFrame([[15, 126], [276, 25]])
    @email_field.label.text = "EMAIL:"
    @email_field.delegate = self
    @email_field.returnKeyType = UIReturnKeyGo
    sign_up_container.addSubview(@email_field)

    @button =  UIButton.buttonWithType UIButtonTypeCustom
    @button.frame = [[7,164], [self.view.frame.size.width - 14, 44]]
    @button.titleLabel.font = UIFont.boldSystemFontOfSize(20)
    @button.titleLabel.shadowOffset = [0, 0.5]
    @button.setTitleShadowColor(UIColor.darkGrayColor, forState:UIControlStateNormal)
    @button.setBackgroundImage("halfbutton.png".uiimage.stretchable([22,22,21,21]), forState:UIControlStateNormal)
    @button.setBackgroundImage("halfbutton_down.png".uiimage.stretchable([22,22,21,21]), forState:UIControlStateHighlighted)
    @button.setTitle("Next", forState:UIControlStateNormal)
    @button.enabled = false
    scroll_view.addSubview(@button)

    scroll_view.contentSize = [320, CGRectGetMaxY(@button.frame) + 7]
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    @username_field.addTarget(self, action: :on_text_editing_changed, forControlEvents:UIControlEventEditingChanged)
    @password_field.addTarget(self, action: :on_text_editing_changed, forControlEvents:UIControlEventEditingChanged)
    @email_field.addTarget(self, action: :on_text_editing_changed, forControlEvents:UIControlEventEditingChanged)
    @button.addTarget(self, action: :on_next, forControlEvents:UIControlEventTouchUpInside)
  end

  def on_text_editing_changed
    @button.enabled = form_valid?
  end

  def viewWillAppear(animated)
    super
    navigationController.setNavigationBarHidden(false, animated:true)
  end

  def textFieldShouldReturn(textfield)
    case textfield
    when @username_field
      @password_field.becomeFirstResponder
    when @password_field
      @email_field.becomeFirstResponder
    when @email_field
      on_next
    end
  end

  def textField(textField, shouldChangeCharactersInRange:range, replacementString:string)
    # probably shouldn't allow weird characters
    true
  end

  def on_next
    return unless form_valid?
    @username_field.resignFirstResponder
    @password_field.resignFirstResponder
    @email_field.resignFirstResponder
    self.show_hud
    # call backend and create user i guess?
    User.sign_up username: @username_field.text, password: @password_field.text, email: @email_field.text do |success|
      self.hide_hud success
      if success
        self.navigationController.pushViewController(ConnectVC.alloc.init, animated:true)
      end
    end

  end

  def form_valid?
    @username_field.text && @username_field.text.length > 3 && @password_field.text && @password_field.text.length > 3 && @email_field.text && @email_field.text.length > 0 && !(@email_field.text =~ /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i).nil?
  end
end
