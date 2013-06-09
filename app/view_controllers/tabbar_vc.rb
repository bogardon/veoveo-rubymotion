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

    profile_nav_vc = UINavigationController.alloc.initWithRootViewController(ProfileVC.alloc.init)
    profile_nav_vc.tabBarItem.setFinishedSelectedImage("profile_selected.png".uiimage, withFinishedUnselectedImage:"profile.png".uiimage)
    profile_nav_vc.tabBarItem.imageInsets = [6,0,-6,0]

    self.viewControllers = [feed_nav_vc, map_nav_vc, profile_nav_vc]
    self.selectedIndex = MAP_INDEX
    self
  end

  def viewDidLoad
    super
    self.tabBar.backgroundImage = "footer.png".uiimage
    self.tabBar.frame = [[0, self.tabBar.superview.frame.size.height - 40], [self.tabBar.frame.size.width, 40]]
    self.tabBar.superview[0].frame = [[0,0], [self.tabBar.superview.frame.size.width, self.tabBar.superview.frame.size.height - 40]]

    # setting nil actually uses some system default.
    self.tabBar.selectionIndicatorImage = UIImage.alloc.init
  end

end
