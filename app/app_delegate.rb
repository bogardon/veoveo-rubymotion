class AppDelegate

  def application(application,didFinishLaunchingWithOptions: launchOptions)
    setup_appearance_proxies
    setup_http_cache
    setup_main_screen
    fade_launch_image
    true
  end

  def application(application, openURL:url, sourceApplication:sourceApplication, annotation:annotation)
    FBSession.activeSession.handleOpenURL url
  end

  def applicationDidBecomeActive(application)
    FBSession.activeSession.handleDidBecomeActive
  end

  def applicationWillTerminate(application)
    FBSession.activeSession.close
  end

  def setup_http_cache
    cache = NSURLCache.alloc.initWithMemoryCapacity 4*1024*1024,
      diskCapacity: 20*1024*1024,
      diskPath: nil
    NSURLCache.setSharedURLCache(cache)
  end

  def setup_appearance_proxies
    Teacup::Appearance.apply
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
    end
  end

  def fade_launch_image
    @launchImage = UIImageView.alloc.initWithImage "Default-568h.png".uiimage
    @window.addSubview @launchImage
    UIView.animateWithDuration(0.5, delay:0.5, options:UIViewAnimationOptionCurveEaseInOut, animations:
    lambda do
     @launchImage.alpha = 0
    end, completion:
    lambda do |completed|
     @launchImage.removeFromSuperview
     @launchImage = nil
    end)
  end
end
