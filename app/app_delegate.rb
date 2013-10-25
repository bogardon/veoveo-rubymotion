class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    setup_appearance_proxies # basic styling
    setup_http_cache # NSURLCache
    setup_main_screen # rootViewController
    fade_launch_image
    setup_testflight
    User.register_push
    handle_push(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) if launchOptions
    LocationManager.start
    Facebook.connect false
    true
  end

  def application(application, didReceiveRemoteNotification:userInfo)
    # {"aps"=>{"badge"=>1, "alert"=>"karina found das keyboard!"}, "spot_id"=>99}
    case UIApplication.sharedApplication.applicationState
    when UIApplicationStateActive
      alert = BW::UIAlertView.new(:message => userInfo['aps']['alert'], :buttons => "OK", :on_click => (lambda do |alert|
        handle_push userInfo, true
      end))
      alert.show
    else
      handle_push userInfo
    end

  end

  def application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    device_token = deviceToken.description.gsub(" ", "").gsub("<", "").gsub(">", "")
    User.patch_device_token device_token
  end

  def application(application, didFailToRegisterForRemoteNotificationsWithError:error)
  end

  def application(application, openURL:url, sourceApplication:sourceApplication, annotation:annotation)
    FBSession.activeSession.handleOpenURL url
  end

  def applicationDidBecomeActive(application)
    FBSession.activeSession.handleDidBecomeActive
  end

  def applicationWillEnterForeground(application)
  end

  def applicationDidEnterBackground(application)
    # clear badge on bg?
    UIApplication.sharedApplication.applicationIconBadgeNumber = 0
    User.persist_user
  end

  def applicationWillTerminate(application)
    FBSession.activeSession.close
  end

  def application(application, didReceiveLocalNotification:notification)
    # not sure where we're supposed to go here...
  end

  def handle_push(userInfo, animated=false)
    return unless userInfo
    # {"aps"=>{"badge"=>1, "alert"=>"karina found das keyboard!"}, "spot_id"=>99}
    if spot_id = userInfo['spot_id']
      spot = Spot.merge_or_insert({"id" => spot_id})
      vc = SpotVC.alloc.initWithSpot spot
      @tab_bar.selectedViewController.pushViewController(vc, animated:animated)
    elsif user_id = userInfo['user_id']
      user = User.merge_or_insert({"id" => user_id})
      vc = ProfileVC.new user
      @tab_bar.selectedViewController.pushViewController(vc, animated:animated)
    end
  end

  def setup_testflight
    config = NSBundle.mainBundle.objectForInfoDictionaryKey('config', Hash)
    testflight_token = config['testflight']['appToken']
    TestFlight.setDeviceIdentifier UIDevice.currentDevice.uniqueIdentifier
    TestFlight.takeOff(testflight_token) if testflight_token.length > 0
  end

  def setup_http_cache
    cache = NSURLCache.alloc.initWithMemoryCapacity 4*1024*1024,
      diskCapacity: 20*1024*1024,
      diskPath: nil
    NSURLCache.setSharedURLCache(cache)
  end

  def setup_appearance_proxies
    UINavigationBar.appearance.setBackgroundImage("header.png".uiimage, forBarMetrics:UIBarMetricsDefault)
    UIBarButtonItem.appearance.setBackgroundImage("navbutton.png".uiimage.stretchable([16,5,15,5]), forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
    UIBarButtonItem.appearance.setBackgroundImage('navbutton_down.png'.uiimage.stretchable([16,5,15,5]), forState:UIControlStateHighlighted, barMetrics:UIBarMetricsDefault)

    UIBarButtonItem.appearance.setBackButtonBackgroundImage('backbutton.png'.uiimage.stretchable([16,14,16,4]), forState:UIControlStateNormal, barMetrics:UIBarMetricsDefault)
    UIBarButtonItem.appearance.setBackButtonBackgroundImage('backbutton_down.png'.uiimage.stretchable([16,14,16,4]), forState:UIControlStateHighlighted, barMetrics:UIBarMetricsDefault)

    offset = NSValue.valueWithUIOffset(UIOffsetMake(0, 1))
    text_attributes = {UITextAttributeFont => UIFont.boldSystemFontOfSize(12), UITextAttributeTextShadowOffset => offset}
    UIBarButtonItem.appearance.setTitleTextAttributes(text_attributes, forState:UIControlStateNormal)
    UIBarButtonItem.appearance.setTitleTextAttributes(text_attributes, forState:UIControlStateHighlighted)

    UIBarButtonItem.appearance.setTitlePositionAdjustment([0,0], forBarMetrics:UIBarMetricsDefault)
  end

  def setup_main_screen
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.backgroundColor = UIColor.blackColor
    @tab_bar = TabBarVC.alloc.init
    @window.rootViewController = @tab_bar
    @window.makeKeyAndVisible

    if User.current.nil?
      # show landing
      @tab_bar.show_landing(false)
    else
      @tab_bar.selectedIndex = TabBarVC::MAP_INDEX
    end
  end

  def fade_launch_image
    image_name = Device.screen.height == 568 ? "Default-568h.png" : "Default.png"
    launchImage = UIImageView.alloc.initWithImage image_name.uiimage
    @window.addSubview launchImage
    UIView.animateWithDuration(0.5, delay:0.5, options:UIViewAnimationOptionCurveEaseInOut, animations:
    lambda do
     launchImage.alpha = 0
    end, completion:
    lambda do |completed|
     launchImage.removeFromSuperview
    end)
  end
end
