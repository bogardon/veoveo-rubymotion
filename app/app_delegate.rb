class AppDelegate < PM::Delegate

  def on_load(application, launch_options)
    setup_appearance_proxies
    setup_http_cache
    setup_main_screen
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
end
