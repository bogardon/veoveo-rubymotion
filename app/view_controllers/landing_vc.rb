class LandingVC < UIViewController
  stylesheet :landing_screen
  layout do
    subview(UIImageView, :background)
    subview(UIButton, :sign_up).when(UIControlEventTouchUpInside) do
      # go sign up
      open SignUpScreen.new
    end
    subview(UIButton, :sign_in).when(UIControlEventTouchUpInside) do
      # go sign in
    end
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
