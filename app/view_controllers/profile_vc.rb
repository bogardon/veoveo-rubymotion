class ProfileVC < UIViewController
  include ViewControllerHelpers
  stylesheet :profile_vc

  attr_accessor :user

  PROFILE_SECTION = 0
  FEED_SECTION = 1
  PROFILE_IDENTIFIER = "PROFILE_IDENTIFIER"
  FEED_IDENTIFIER = "FEED_IDENTIFIER"
  LOAD_MORE_CELL_IDENTIFIER = "LOAD_MORE_CELL_IDENTIFIER"
  LIMIT = 10

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    flow.minimumLineSpacing = 0
    @collection_view = subview(CollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.alwaysBounceVertical = true
    @collection_view.registerClass(ProfileCell, forCellWithReuseIdentifier:PROFILE_IDENTIFIER)
    @collection_view.registerClass(UserFeedCell, forCellWithReuseIdentifier:FEED_IDENTIFIER)
    @collection_view.registerClass(LoadMoreCell, forSupplementaryViewOfKind:UICollectionElementKindSectionFooter, withReuseIdentifier:LOAD_MORE_CELL_IDENTIFIER)
  end

  def initialize(user)
    @user = user
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :user_did_log_in, name:CurrentUserDidLoginNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'on_spot_did_add:', name:SpotDidAddNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: 'on_spot_did_delete:', name:SpotDidDeleteNotification, object:nil)
    @more_to_load = true
    @answers = []
    reload_user
    reload_answers
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    super
  end

  def user_did_log_in
    self.user = User.current
    reload_user
    reload_answers
    @collection_view.reloadData if @collection_view
  end

  def on_spot_did_add(notification)
    reload_answers
  end

  def on_spot_did_delete(notification)
    spot = notification.object
    if self.user && @answers
      @answers.delete_if do |a|
        a.spot == spot
      end
      @collection_view.reloadData if @collection_view
    end
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    @refresh = UIRefreshControl.alloc.init
    @refresh.addTarget(self, action: :reload_answers, forControlEvents:UIControlEventValueChanged)
    @collection_view.addSubview(@refresh)
    configure_nav_button
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

  def more_to_load?
    @answers && @answers.count > 0 && @answers.count % LIMIT == 0
  end

  def reload_user
    return unless self.user
    return if self.user.is_current?
    @user_query.connection.cancel if @user_query
    @user_query = User.get_id self.user.id do |response, user|
      if response.ok?
        self.user = user
      end
    end
  end

  def reload_answers(offset=0)
    return unless self.user
    offset = 0 unless offset.is_a?(Fixnum)

    @answers_query.connection.cancel if @answers_query
    @answers_query = User.get_answers self.user.id, LIMIT, offset do |response, answers|

      if response.ok?
        @more_to_load = answers.count == LIMIT
        if offset > 0
          old_count = @answers.count
          @answers += answers
          new_count = @answers.count

          index_paths = (old_count...new_count).map do |i|
            [FEED_SECTION, i].nsindexpath
          end
          @collection_view.insertItemsAtIndexPaths(index_paths) if @collection_view
        else
          @answers = answers
          @collection_view.reloadData if @collection_view
        end

      end
      @refresh.endRefreshing if @refresh
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
      [0,0,10,0]
    end
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when PROFILE_SECTION
      1
    when FEED_SECTION
      @answers ? @answers.count : 0
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
      cell.answer = @answers[indexPath.item]
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    case indexPath.section
    when PROFILE_SECTION
    when FEED_SECTION
      answer = @answers[indexPath.item]
      spot_vc = SpotVC.alloc.initWithSpot answer.spot
      self.navigationController.pushViewController(spot_vc, animated:true)
    else
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, referenceSizeForFooterInSection:section)
    case section
    when PROFILE_SECTION
      [0,0]
    when FEED_SECTION
      @more_to_load ? [320, 30] : [0,0]
    else
      [0,0]
    end
  end

  def collectionView(collectionView, viewForSupplementaryElementOfKind:kind, atIndexPath:indexPath)
    case indexPath.section
    when PROFILE_SECTION
      nil
    when FEED_SECTION
      unless @more_to_load
        nil
      else
        # [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionHeaderView" forIndexPath:indexPath];
        reload_answers(@answers.count)

        collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier:LOAD_MORE_CELL_IDENTIFIER, forIndexPath:indexPath)
      end
    else
      nil
    end
  end


end
