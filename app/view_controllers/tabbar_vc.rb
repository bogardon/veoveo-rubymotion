class TabBarVC < UITabBarController
  include BW::KVO

  FEED_INDEX=0
  MAP_INDEX=1
  PROFILE_INDEX=2

  def init
    super
    feed_vc = FeedVC.alloc.init

    observe(feed_vc, :unread_count) do |old_value, new_value|
      @notification_label.hidden = new_value == 0
      @notification_label.text = new_value.to_s
    end

    feed_nav_vc = UINavigationController.alloc.initWithRootViewController(feed_vc)
    feed_nav_vc.tabBarItem.setFinishedSelectedImage("activity.png".uiimage, withFinishedUnselectedImage:"activity_icon_disabled.png".uiimage)
    feed_nav_vc.tabBarItem.imageInsets = [6,0,-6,0]

    map_nav_vc = UINavigationController.alloc.initWithRootViewController(MapVC.alloc.init)
    map_nav_vc.tabBarItem.setFinishedSelectedImage("map_icon_active.png".uiimage, withFinishedUnselectedImage:"map_icon_inactive.png".uiimage)
    map_nav_vc.tabBarItem.imageInsets = [6,0,-6,0]

    profile_vc = ProfileVC.new User.current
    profile_nav_vc = UINavigationController.alloc.initWithRootViewController(profile_vc)
    profile_nav_vc.tabBarItem.setFinishedSelectedImage("profile.png".uiimage, withFinishedUnselectedImage:"profile_icon_disabled.png".uiimage)
    profile_nav_vc.tabBarItem.imageInsets = [6,0,-6,0]

    self.viewControllers = [feed_nav_vc, map_nav_vc, profile_nav_vc]

    NSNotificationCenter.defaultCenter.addObserver(self, selector: :show_landing, name:CurrentUserDidLogoutNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :user_did_login, name:CurrentUserDidLoginNotification, object:nil)
    self.selectedIndex = MAP_INDEX

    self
  end

  def user_did_login
    self.viewControllers.each do |nav|
      nav.popToRootViewControllerAnimated(false)
    end
    self.selectedIndex = MAP_INDEX
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    super
  end

  def viewDidLoad
    super

    self.tabBar.backgroundImage = "bottom_nav.png".uiimage
    self.tabBar.frame = [[0, self.tabBar.superview.frame.size.height - 40], [self.tabBar.frame.size.width, 40]]
    self.tabBar.superview.subviews[0].frame = [[0,0], [self.tabBar.superview.frame.size.width, self.tabBar.superview.frame.size.height - 40]]

    size = CGSizeMake(120,40)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    [127, 181, 163].uicolor.setFill
    context = UIGraphicsGetCurrentContext()
    CGContextFillRect(context, [[0,38],[120,2]])
    selection_indicator_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()


    # setting nil actually uses some system default.
    self.tabBar.selectionIndicatorImage = selection_indicator_image

    image = "notification_badge.png".uiimage.center_stretch

    @notification_label = UILabel.alloc.initWithFrame [[60,self.view.frame.size.height - 35], image.size]
    @notification_label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin
    @notification_label.textColor = UIColor.whiteColor
    @notification_label.font = UIFont.boldSystemFontOfSize(8)
    @notification_label.textAlignment = NSTextAlignmentCenter
    @notification_label.backgroundColor = UIColor.colorWithPatternImage(image)
    @notification_label.text = "0"
    @notification_label.hidden = true

    self.view.addSubview(@notification_label)
  end

  def show_landing(animated=true)
    landing = LandingVC.alloc.init
    nav = UINavigationController.alloc.initWithRootViewController(landing)
    self.presentViewController(nav, animated:animated, completion:nil)
  end

end
