class FeedVC < UIViewController
  include ViewControllerHelpers

  NOTIFICATION_FEED_CELL_IDENTIFIER = "NOTIFICATION_FEED_CELL_IDENTIFIER"
  LOAD_MORE_CELL_IDENTIFIER = "LOAD_MORE_CELL_IDENTIFIER"
  LIMIT = 10

  attr_accessor :unread_count
  attr_accessor :notifications

  def init
    super
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:CurrentUserDidLoginNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:CurrentUserDidUpdateFollowedUsers, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:SpotDidDeleteNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:UIApplicationWillEnterForegroundNotification, object:nil)
    @more_to_load = true
    @unread_count = 0
    @notifications = []
    reload
    self
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    @query.connection.cancel if @query
    super
  end

  def loadView
    super
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    flow.minimumLineSpacing = 0
    @collection_view = CollectionView.alloc.initWithFrame(self.view.bounds, collectionViewLayout:flow)
    @collection_view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth
    @collection_view.delegate = self
    @collection_view.dataSource = self
    @collection_view.alwaysBounceVertical = true

    @collection_view.registerClass(NotificationCell, forCellWithReuseIdentifier:NOTIFICATION_FEED_CELL_IDENTIFIER)
    @collection_view.registerClass(LoadMoreCell, forSupplementaryViewOfKind:UICollectionElementKindSectionFooter, withReuseIdentifier:LOAD_MORE_CELL_IDENTIFIER)

    background = "bg.png".uiimageview
    background.contentMode = UIViewContentModeScaleAspectFill

    @collection_view.backgroundView = background
    self.view.addSubview(@collection_view)
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar

    add_right_nav_button "Find Friends", self, :on_find_friends

    @refresh = UIRefreshControl.alloc.init
    @refresh.addTarget(self, action: :reload, forControlEvents:UIControlEventValueChanged)
    @collection_view.addSubview(@refresh)
  end

  def viewDidAppear(animated)
    super
    self.unread_count = 0
    Notification.mark_all_as_read
  end

  def on_find_friends
    if Facebook.is_open?
      vc = FindFriendsVC.alloc.init
      vc.can_invite = true
      self.navigationController.pushViewController(vc, animated:true)
    else
      alert = BW::UIAlertView.new(:title => "Find Friends", :message => "You must connect your Facebook account to continue.", :buttons => ["Connect", "Cancel"], :on_click => (lambda do |alert|
        if alert.clicked_button.index == 0
          show_hud
          Facebook.connect true do |response, json|
            hide_hud response.ok?
            if response.ok?
              vc = FindFriendsVC.alloc.init
              vc.can_invite = true
              self.navigationController.pushViewController(vc, animated:true)
            end
          end
        end
      end))
      alert.show
    end
  end

  def reload(offset=0)
    offset = 0 unless offset.is_a?(Fixnum)
    return unless User.current
    @query.connection.cancel if @query
    Notification.get_feed LIMIT, offset do |response, notifications|
      if response.ok?
        @more_to_load = notifications.count == LIMIT
        if offset > 0
          old_count = @notifications.count
          @notifications += notifications
          new_count = @notifications.count

          index_paths = (old_count...new_count).map do |i|
            [0, i].nsindexpath
          end
          @collection_view.insertItemsAtIndexPaths(index_paths) if @collection_view
        else
          @notifications = notifications
          @collection_view.reloadData if @collection_view
        end

        self.unread_count = @notifications.reduce(0) do |a,n|
          if n.unread
            a + 1
          else
            a
          end
        end
      end
      @refresh.endRefreshing if @refresh
    end
  end

  def numberOfSectionsInCollectionView(collectionView)
    1
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    @notifications ? @notifications.count : 0
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    NotificationCell.size_for_notification(@notifications[indexPath.item])
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    [7,7,7,7]
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    cell = collectionView.dequeueReusableCellWithReuseIdentifier(NOTIFICATION_FEED_CELL_IDENTIFIER, forIndexPath:indexPath)
    cell.image_button.tag = indexPath.item

    cell.image_button.removeTarget(self, action: "on_profile:", forControlEvents:UIControlEventTouchUpInside)
    cell.image_button.addTarget(self, action: "on_profile:", forControlEvents:UIControlEventTouchUpInside)

    cell.notification = @notifications[indexPath.item]
    cell
  end

  #- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section

  def collectionView(collectionView, layout:collectionViewLayout, referenceSizeForFooterInSection:section)
    @more_to_load ? [320,30] : [0, 0]
  end

#-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

  def collectionView(collectionView, viewForSupplementaryElementOfKind:kind, atIndexPath:indexPath)
    reload(@notifications.count) if @more_to_load
    collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier:LOAD_MORE_CELL_IDENTIFIER, forIndexPath:indexPath)
  end

  def on_profile(sender)
    user = @notifications[sender.tag].src_user
    profile_vc = ProfileVC.new user
    self.navigationController.pushViewController(profile_vc, animated:true)
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    notification = @notifications[indexPath.item]
    vc = case notification.notifiable_type
    when "Answer"
      vc = SpotVC.alloc.initWithSpot notification.notifiable.spot
    when "Relationship"
      vc = ProfileVC.new notification.src_user
    end
    self.navigationController.pushViewController(vc, animated:true)
  end

end
