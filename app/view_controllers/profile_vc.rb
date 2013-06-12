class ProfileVC < UIViewController
  include NavigationHelpers

  def viewDidLoad
    super
    add_right_nav_button "Logout", self, :on_logout
  end

  def on_logout
    User.current = nil
  end
end
