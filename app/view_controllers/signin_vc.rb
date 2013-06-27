class SignInVC < UIViewController
  include ViewControllerHelpers
  stylesheet :signin_screen
  layout do
    subview(UIImageView, :background)
    subview(UIScrollView, :scrollview) do
      subview(UIImageView, :signin_form_container) do
        @username_field = subview(FormTextField, :username, y: 5, delegate: self)
        @username_field.becomeFirstResponder
        subview(UIImageView, :separator, y: 35)
        @password_field = subview(FormTextField, :password, y: 41, delegate: self)

        [@username_field, @password_field].each do |textfield|
          textfield.when(UIControlEventEditingChanged) do
            @button.enabled = form_valid?
          end
        end

      end
      @button = subview(UIButton, :button, y: 85)
      @button.setTitle("Sign In", forState:UIControlStateNormal)
      @button.enabled = false
      @button.when(UIControlEventTouchUpInside) do
        on_sign_in
      end
    end.alwaysBounceVertical = true
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
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
    @username_field.text && @password_field.text
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
