class LandingVC < UIViewController
  stylesheet :landing_screen
  layout do
    subview(UIImageView, :background)

    subview(UIButton, :sign_up) do |sign_up|
      sign_up.addTarget(self, action: :on_sign_up, forControlEvents:UIControlEventTouchUpInside)
    end

    subview(UIButton, :sign_in) do |sign_in|
      sign_in.addTarget(self, action: :on_sign_in, forControlEvents:UIControlEventTouchUpInside)
    end
  end

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
