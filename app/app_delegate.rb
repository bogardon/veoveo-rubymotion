class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    # Cache
    cache = NSURLCache.alloc.initWithMemoryCapacity 4*1024*1024,
      diskCapacity: 20*1024*1024,
      diskPath: nil
    NSURLCache.setSharedURLCache(cache)

    @tab_bar_controller = TabBarController.alloc.init
    vc = UIViewController.alloc.init
    vc.view.backgroundColor = UIColor.blueColor
    @tab_bar_controller.viewControllers = [vc]

    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.rootViewController = @tab_bar_controller
    @window.makeKeyAndVisible

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
end
