class TabBarVC < UITabBarController

  FEED_INDEX=0
  MAP_INDEX=1
  PROFILE_INDEX=2

  def init
    super
    feed_nav_vc = UINavigationController.alloc.initWithRootViewController(FeedVC.alloc.init)
    feed_nav_vc.tabBarItem.setFinishedSelectedImage("activity_selected.png".uiimage, withFinishedUnselectedImage:"activity.png".uiimage)
    feed_nav_vc.tabBarItem.imageInsets = [6,0,-6,0]

    map_nav_vc = UINavigationController.alloc.initWithRootViewController(MapVC.alloc.init)
    map_nav_vc.tabBarItem.setFinishedSelectedImage("finds_selected.png".uiimage, withFinishedUnselectedImage:"finds.png".uiimage)
    map_nav_vc.tabBarItem.imageInsets = [-4,0,4,0]

    profile_vc = ProfileVC.new User.current
    profile_nav_vc = UINavigationController.alloc.initWithRootViewController(profile_vc)
    profile_nav_vc.tabBarItem.setFinishedSelectedImage("profile_selected.png".uiimage, withFinishedUnselectedImage:"profile.png".uiimage)
    profile_nav_vc.tabBarItem.imageInsets = [6,0,-6,0]

    self.viewControllers = [feed_nav_vc, map_nav_vc, profile_nav_vc]

    @login_observer = App.notification_center.observe CurrentUserDidLoginNotification do |notification|
      self.selectedIndex = MAP_INDEX
    end

    @logout_observer = App.notification_center.observe CurrentUserDidLogoutNotification do |notification|
      show_landing(true)
    end

    NSNotificationCenter.defaultCenter.addObserver(self, selector: :show_landing, name:CurrentUserDidLogoutNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :user_did_login, name:CurrentUserDidLoginNotification, object:nil)

    self
  end

  def user_did_login
    self.selectedIndex = MAP_INDEX
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    super
  end

  def viewDidLoad
    super
    self.tabBar.backgroundImage = "footer.png".uiimage
    self.tabBar.frame = [[0, self.tabBar.superview.frame.size.height - 40], [self.tabBar.frame.size.width, 40]]
    self.tabBar.superview[0].frame = [[0,0], [self.tabBar.superview.frame.size.width, self.tabBar.superview.frame.size.height - 40]]


    selection_indicator_image = "selector.png".uiimage
    size = CGSizeMake(selection_indicator_image.size.width,40)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    UIColor.clearColor.setFill
    context = UIGraphicsGetCurrentContext()
    CGContextFillRect(context, [[0,0],size])
    selection_indicator_image.drawInRect([[0,size.height-2],[size.width, 2]])
    selection_indicator_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()


    # setting nil actually uses some system default.
    self.tabBar.selectionIndicatorImage = selection_indicator_image
  end

  def show_landing(animated=true)
    landing = LandingVC.alloc.init
    nav = UINavigationController.alloc.initWithRootViewController(landing)
    self.presentViewController(nav, animated:animated, completion:lambda do
      self.viewControllers.each do |nav|
        nav.popToRootViewControllerAnimated(false)
      end
    end)
  end

end
