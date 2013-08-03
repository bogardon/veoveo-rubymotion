class ProfileVC < UIViewController
  include ViewControllerHelpers
  stylesheet :profile_vc

  attr_accessor :user

  PROFILE_SECTION = 0
  FEED_SECTION = 1
  PROFILE_IDENTIFIER = "PROFILE_IDENTIFIER"
  FEED_IDENTIFIER = "FEED_IDENTIFIER"

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    flow.minimumLineSpacing = 0
    @collection_view = subview(CollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.alwaysBounceVertical = true

    @collection_view.registerClass(ProfileCell, forCellWithReuseIdentifier:PROFILE_IDENTIFIER)
    @collection_view.registerClass(UserFeedCell, forCellWithReuseIdentifier:FEED_IDENTIFIER)
  end

  def initialize(user)
    @user = user
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :user_did_log_in, name:CurrentUserDidLoginNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'on_spot_did_add:', name:SpotDidAddNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'on_spot_did_delete:', name:SpotDidDeleteNotification, object:nil)
    reload
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    super
  end

  def user_did_log_in
    self.user = User.current
    reload
  end

  def on_spot_did_add(notification)
    reload
  end

  def on_spot_did_delete(notification)
    spot = notification.object
    if self.user && self.user.answers
      self.user.answers.delete_if do |a|
        a.spot == spot
      end
      @collection_view.reloadData if @collection_view
    end
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    @refresh = UIRefreshControl.alloc.init
    @refresh.addTarget(self, action: :reload, forControlEvents:UIControlEventValueChanged)
    @refresh.addTarget(self, action: :reload, forControlEvents:UIControlEventValueChanged)
    @collection_view.addSubview(@refresh)
  end

  def user=(user)
    @user = user
    configure_nav_button
  end

  def configure_nav_button
    return unless self.user
    if self.user.is_current?
      add_right_nav_button "Logout", self, :on_logout
    elsif self.user.following
      add_right_nav_button "Unfollow", self, :on_relationship
    elsif !self.user.following
      add_right_nav_button "Follow", self, :on_relationship
    else
    end
  end

  def reload
    return unless self.user
    User.get_id self.user.id do |response, user|
      if response.ok?
        self.user = user
        @collection_view.reloadData if @collection_view
        @refresh.endRefreshing if @refresh
      end
    end
  end

  def on_relationship
    show_hud
    self.user.toggle_following do |response, json|
      hide_hud response.ok?
      configure_nav_button
    end
  end

  def on_following
    return unless self.user
    vc = FollowingVC.new self.user
    self.navigationController.pushViewController(vc, animated:true)
  end

  def on_logout
    User.current = nil
  end

  def on_take_photo
    return unless self.user && self.user.is_current?
    source = BW::Device.camera.rear || BW::Device.camera.any
    source.picture(media_types: [:image], allows_editing: true) do |result|
      unless result[:error]
        photo = result[:edited_image]
        self.show_hud
        User.upload_avatar photo do |response, user|
          self.hide_hud response.ok?
          @collection_view.reloadData
        end
      end
    end if source
  end

  def numberOfSectionsInCollectionView(collectionView)
    2
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    case section
    when PROFILE_SECTION
      [10,7,10,7]
    when FEED_SECTION
      [0,0,25,0]
    end
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when PROFILE_SECTION
      1
    when FEED_SECTION
      self.user && self.user.answers ? self.user.answers.count : 0
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    case indexPath.section
    when PROFILE_SECTION
      [306,90]
    when FEED_SECTION
      [306,50]
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when PROFILE_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(PROFILE_IDENTIFIER, forIndexPath:indexPath)

      cell.image_button.removeTarget(self, action: :on_take_photo, forControlEvents:UIControlEventTouchUpInside)
      cell.image_button.addTarget(self, action: :on_take_photo, forControlEvents:UIControlEventTouchUpInside)

      cell.following_button.removeTarget(self, action: :on_following, forControlEvents:UIControlEventTouchUpInside)
      cell.following_button.addTarget(self, action: :on_following, forControlEvents:UIControlEventTouchUpInside)

      cell.user = self.user
      cell
    when FEED_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(FEED_IDENTIFIER, forIndexPath:indexPath)
      cell.answer = self.user.answers[indexPath.item]
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    case indexPath.section
    when PROFILE_SECTION
    when FEED_SECTION
      answer = self.user.answers[indexPath.item]
      spot_vc = SpotVC.alloc.initWithSpot answer.spot
      self.navigationController.pushViewController(spot_vc, animated:true)
    else
    end
  end

end
