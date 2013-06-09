class SignUpVC < UIViewController
  stylesheet :signup_screen
  layout do
    subview(UIImageView, :background)
    subview(UIScrollView, :scrollview) do
      subview(UIImageView, :signup_form_container) do
        subview(UILabel, :prompt, text: "1. Pick a Username & Password")
        @username_field = subview(FormTextField, :username, y: 55, delegate: self)
        @username_field.becomeFirstResponder
        subview(UIImageView, :separator, y: 85)
        @password_field = subview(FormTextField, :password, y: 91, delegate: self)
        subview(UIImageView, :separator, y: 121)
        @email_field = subview(FormTextField, :email, y: 126, delegate:self)

        [@username_field, @password_field, @email_field].each do |textfield|
          textfield.when(UIControlEventEditingChanged) do
            @button.enabled = formValid
          end
        end

      end
      @button = subview(UIButton, :button, y: 171)
      @button.setTitle("Next", forState:UIControlStateNormal)
      @button.enabled = false
      @button.when(UIControlEventTouchUpInside) do
        onNext
      end
    end.alwaysBounceVertical = true
  end

  def viewDidLoad
    super
    self.title = nil
    self.navigationItem.titleView = UIImageView.alloc.initWithImage "logo.png".uiimage;
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
      onNext
    end
  end

  def textField(textField, shouldChangeCharactersInRange:range, replacementString:string)
    # probably shouldn't allow weird characters
    true
  end

  def onNext
    return unless formValid
    # call backend and create user i guess?
    User.sign_up username: @username_field.text, password: @password_field.text, email: @email_field.text do |success|
      dismissViewControllerAnimated(true, completion:nil) if success
    end

  end

  def formValid
    @username_field.text && @username_field.text.length > 3 && @password_field.text && @password_field.text.length > 3 && @email_field.text && @email_field.text.length > 0 && (@email_field.text =~ /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i).present?
  end
end
