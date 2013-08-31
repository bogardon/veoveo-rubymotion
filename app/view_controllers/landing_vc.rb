class LandingVC < UIViewController

  def on_sign_in
    self.navigationController.pushViewController(SignInVC.alloc.init, animated:true)
  end

  def on_sign_up
    self.navigationController.pushViewController(SignUpVC.alloc.init, animated:true)
  end

  def init
    super
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal
    self
  end

  def loadView
    super
    background = Device.screen.height == 568 ? "Default-568h.png".uiimageview : "Default.png".uiimageview
    background.frame = [[0, -20], background.frame.size]
    self.view.addSubview(background)

    sign_up = UIButton.buttonWithType(UIButtonTypeCustom)
    sign_up.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    sign_up.setTitle("Sign Up", forState:UIControlStateNormal)
    sign_up.frame = [[48, self.view.frame.size.height - 146], [224, 44]]
    sign_up.titleLabel.shadowOffset = [0, 0.5]
    sign_up.setBackgroundImage('signup_button.png'.uiimage.stretchable([22,4,22,4]), forState:UIControlStateNormal)
    sign_up.setBackgroundImage('signup_button_down.png'.uiimage.stretchable([22,4,22,4]), forState:UIControlStateHighlighted)
    sign_up.setTitleShadowColor(UIColor.darkGrayColor, forState:UIControlStateNormal)
    sign_up.setTitleShadowColor(UIColor.darkGrayColor, forState:UIControlStateHighlighted)
    sign_up.titleLabel.font = UIFont.boldSystemFontOfSize(15)
    sign_up.addTarget(self, action: :on_sign_up, forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(sign_up)

    sign_in = UIButton.buttonWithType(UIButtonTypeCustom)
    sign_in.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    sign_in.setTitle("Sign In", forState:UIControlStateNormal)
    sign_in.frame = [[48, self.view.frame.size.height - 92], [224, 44]]
    sign_in.setBackgroundImage('signin_button.png'.uiimage.stretchable([22,4,22,4]), forState:UIControlStateNormal)
    sign_in.setBackgroundImage('signin_button_down.png'.uiimage.stretchable([22,4,22,4]), forState:UIControlStateHighlighted)
    sign_in.setTitleColor(UIColor.darkGrayColor, forState:UIControlStateNormal)
    sign_in.setTitleColor(UIColor.darkGrayColor, forState:UIControlStateHighlighted)
    sign_in.titleLabel.font = UIFont.boldSystemFontOfSize(15)
    sign_in.addTarget(self, action: :on_sign_in, forControlEvents:UIControlEventTouchUpInside)
    self.view.addSubview(sign_in)
  end

  def viewDidLoad
    super
    self.title = nil
    navigationController.navigationBar.hidden = true
  end

  def viewWillAppear(animated)
    super
    navigationController.setNavigationBarHidden(true, animated:true)
  end

end
