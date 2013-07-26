class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    setup_appearance_proxies # basic styling
    setup_http_cache # NSURLCache
    setup_main_screen # rootViewController
    fade_launch_image
    setup_testflight
    User.register_push
    handle_push(launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) if launchOptions
    setup_location_change
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
    when UIApplicationStateInactive
    when UIApplicationStateBackground
      handle_push userInfo
    else
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
    spot = Spot.merge_or_insert({:id => userInfo['spot_id']})
    vc = SpotVC.alloc.initWithSpot spot
    @tab_bar.selectedViewController.pushViewController(vc, animated:animated)
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

  def setup_location_change
    BW::Location.get_significant do |result|
      coordinate = result[:to].coordinate
      app_state = UIApplication.sharedApplication.applicationState

      if User.current && app_state == UIApplicationStateBackground
        fetch_nearby_spots(coordinate)
      end
    end
  end

  def fetch_nearby_spots(coordinate)

    @bg_task = UIApplication.sharedApplication.beginBackgroundTaskWithExpirationHandler(lambda do
      UIApplication.sharedApplication.endBackgroundTask(@bg_task)
      @bg_task = UIBackgroundTaskInvalid
    end)

    # 100 meter radius around center
    region = MKCoordinateRegionMakeWithDistance(coordinate, 200, 200)
    VeoVeoAPI.get_nearby_spots region do |response, spots|
      # skip if no spots found
      if response.ok? && spots.count > 0
        # do not notify twice
        notified_spot_ids = App::Persistence['notified_spot_ids'] || []
        spots_to_notify = spots.reject do |s|
          notified_spot_ids.include?(s.id)
        end
        # store notified spot ids
        App::Persistence['notified_spot_ids'] = notified_spot_ids + spots_to_notify.map(&:id)

        # do not notify unless there's stuff?
        if spots_to_notify.count > 0
          names = spots_to_notify.map do |s|
            s.user.username
          end.uniq

          names_list = case names.count
          when 1
            names.first
          when 2
            names.first + ' and ' + names.last
          else
            # oxford comma
            names[0...-1].join(', ') + " ,and #{names.last}"
          end

          spots_notification = UILocalNotification.alloc.init
          spots_notification.alertBody = "#{names_list} discovered something near you. Find it!"
          spots_notification.userInfo = {latitude: coordinate.latitude, longitude: coordinate.longitude}
          UIApplication.sharedApplication.scheduleLocalNotification(spots_notification)
        end

      end

      # end bg task
      UIApplication.sharedApplication.endBackgroundTask(@bg_task)
      @bg_task = UIBackgroundTaskInvalid

    end
  end
end
