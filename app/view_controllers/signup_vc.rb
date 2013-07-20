class SignUpVC < UIViewController
  include ViewControllerHelpers
  stylesheet :signup_screen
  layout do
    subview(UIImageView, :background)
    scroll_view = subview(UIScrollView, :scrollview) do
      subview(UIImageView, :signup_form_container) do
        subview(UILabel, :prompt, text: "1. Pick a Username & Password")
        @username_field = subview(FormTextField, :username, y: 55, delegate: self)
        @username_field.becomeFirstResponder
        subview(UIImageView, :separator, y: 85)
        @password_field = subview(FormTextField, :password, y: 91, delegate: self)
        subview(UIImageView, :separator, y: 121)
        @email_field = subview(FormTextField, :email, y: 126, delegate:self)

      end
      @button = subview(UIButton, :button, y: 171)
      @button.setTitle("Next", forState:UIControlStateNormal)
      @button.enabled = false
    end
    scroll_view.alwaysBounceVertical = true
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
    return unless formValid
    @username_field.resignFirstResponder
    @password_field.resignFirstResponder
    @email_field.resignFirstResponder
    self.show_hud
    # call backend and create user i guess?
    User.sign_up username: @username_field.text, password: @password_field.text, email: @email_field.text do |success|
      self.hide_hud success
      dismissViewControllerAnimated(true, completion:nil) if success
    end

  end

  def form_valid?
    @username_field.text && @username_field.text.length > 3 && @password_field.text && @password_field.text.length > 3 && @email_field.text && @email_field.text.length > 0 && (@email_field.text =~ /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i).present?
  end
end
