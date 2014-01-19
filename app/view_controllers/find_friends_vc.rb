class FindFriendsVC < UIViewController
  include ViewControllerHelpers

  FOLLOWING_IDENTIFIER = "FOLLOWING_IDENTIFIER"
  ACTION_IDENTIFIER = "ACTION_IDENTIFIER"

  REGISTERED_SECTION = 0
  INVITE_SECTION = 1

  attr_accessor :can_invite

  def init
    super
    @can_invite = false
    reload
    self
  end

  def dealloc
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

    @collection_view.registerClass(FollowingCell, forCellWithReuseIdentifier:FOLLOWING_IDENTIFIER)
    @collection_view.registerClass(LogoutCell, forCellWithReuseIdentifier:ACTION_IDENTIFIER)

    background = "bg.png".uiimageview
    background.contentMode = UIViewContentModeScaleAspectFill

    @collection_view.backgroundView = background
    self.view.addSubview(@collection_view)
  end

  def viewDidLoad
    super
    add_title_to_nav_bar "Facebook Friends"
    # add_right_nav_button "Done", self, :on_done
    @refresh = UIRefreshControl.alloc.init
    @refresh.addTarget(self, action: :reload, forControlEvents:UIControlEventValueChanged)
    @collection_view.addSubview(@refresh)
  end

  def reload
    @query.connection.cancel if @query
    @query = User.find_facebook_friends do |response, users|
      @users = users
      @collection_view.reloadData if @collection_view
      @refresh.endRefreshing if @refresh
    end
  end

  def on_relationship(button)
    user = @users[button.tag]
    user.toggle_following do |response, json|
      @collection_view.reloadData
    end
    @collection_view.reloadData
  end

  def on_done
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def numberOfSectionsInCollectionView(collectionView)
    2
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when REGISTERED_SECTION
      @users ? @users.count : 0
    when INVITE_SECTION
      @can_invite ? 1 : 0
    else
      0
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    [306,45]
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    [7,7,0,7]
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when REGISTERED_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(FOLLOWING_IDENTIFIER, forIndexPath:indexPath)
      cell.user = @users[indexPath.item]
      cell.button.tag = indexPath.item
      cell.button.removeTarget(self, action: "on_relationship:", forControlEvents:UIControlEventTouchUpInside)
      cell.button.addTarget(self, action: "on_relationship:", forControlEvents:UIControlEventTouchUpInside)
      cell
    when INVITE_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(ACTION_IDENTIFIER, forIndexPath:indexPath)
      cell.label.text = "Invite Others"
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    collectionView.deselectItemAtIndexPath(indexPath, animated:true)
    case indexPath.section
    when REGISTERED_SECTION
      profile_vc = ProfileVC.new @users[indexPath.item]
      self.navigationController.pushViewController(profile_vc, animated:true)
    when INVITE_SECTION
      Facebook.invite
    else
    end
  end
end
