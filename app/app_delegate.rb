class AppDelegate < PM::Delegate

  def on_load(application, launch_options)
    setup_appearance_proxies
    setup_http_cache
    setup_main_screen
    fade_launch_image
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
    open LandingScreen.new(nav_bar: true)
  end

  def fade_launch_image
    @launchImage = UIImageView.alloc.initWithImage "Default-568h.png".uiimage
    self.window.addSubview @launchImage
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
