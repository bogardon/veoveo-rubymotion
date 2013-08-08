module LocationManager
  class << self
    def start
      return unless User.current && User.current.spots_nearby_push_enabled
      BW::Location.get_significant do |result|
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
end
