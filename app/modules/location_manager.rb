NOTIFIED_SPOTS_BY_IDS_KEY = "NOTIFIED_SPOTS_BY_IDS_KEY"
module LocationManager
  class << self
    def start
      return unless User.current && User.current.spots_nearby_push_enabled
      BW::Location.get_significant do |result|
        return unless result[:to]
        coordinate = result[:to].coordinate
        app_state = UIApplication.sharedApplication.applicationState

        if User.current && app_state == UIApplicationStateBackground && User.current.spots_nearby_push_enabled
          fetch_nearby_spots(coordinate)
        end
      end
      @started = true
    end

    def stop
      return unless @started
      BW::Location.stop
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
          notified_spots_by_ids = App::Persistence[NOTIFIED_SPOTS_BY_IDS_KEY] ? App::Persistence[NOTIFIED_SPOTS_BY_IDS_KEY].clone : {}

          now = Time.now

          # pick a random one to notify that hasn't been notified in 3 months.
          spot_to_notify = spots.reject do |s|
            notified_spots_by_ids.has_key?(s.id.to_s) && (notified_spots_by_ids[s.id.to_s] + 3.month > now)
          end.sample

          if spot_to_notify
            notified_spots_by_ids[spot_to_notify.id.to_s] = now

            spots_notification = UILocalNotification.alloc.init
            spots_notification.soundName = UILocalNotificationDefaultSoundName
            spots_notification.alertBody = "#{spot_to_notify.user.username} discovered #{spot_to_notify.hint} nearby. Find it!"
            spots_notification.userInfo = {latitude: coordinate.latitude, longitude: coordinate.longitude}
            UIApplication.sharedApplication.scheduleLocalNotification(spots_notification)
          end

          # store notified spot ids
          App::Persistence[NOTIFIED_SPOTS_BY_IDS_KEY] = notified_spots_by_ids
        end

        # end bg task
        UIApplication.sharedApplication.endBackgroundTask(@bg_task)
        @bg_task = UIBackgroundTaskInvalid

      end
    end
  end
end
