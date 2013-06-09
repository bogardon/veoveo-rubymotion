class TabBarVC < UITabBarController

  FEED_INDEX=0
  MAP_INDEX=1
  PROFILE_INDEX=2

  def init
    super
    viewControllers = []
    [FeedVC.alloc.init, MapVC.alloc.init, ProfileVC.alloc.init].each do |vc|
      nav = UINavigationController.alloc.initWithRootViewController(vc)
      viewControllers << nav
    end
    self.viewControllers = viewControllers
    self.selectedIndex = MAP_INDEX
    self
  end

end
