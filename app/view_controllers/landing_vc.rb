class LandingVC < UIViewController
  stylesheet :landing_screen
  layout do
    subview(UIImageView, :background)
    subview(UIButton, :sign_up).when(UIControlEventTouchUpInside) do
      # go sign up
      navigationController.pushViewController(SignUpVC.alloc.init, animated:true)
    end
    subview(UIButton, :sign_in).when(UIControlEventTouchUpInside) do
      # go sign in
      navigationController.pushViewController(SignInVC.alloc.init, animated:true)
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
