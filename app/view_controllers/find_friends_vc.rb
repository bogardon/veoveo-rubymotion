class FindFriendsVC < UIViewController
  include ViewControllerHelpers
  stylesheet :find_friends_vc

  FOLLOWING_IDENTIFIER = "FOLLOWING_IDENTIFIER"

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    flow.minimumLineSpacing = 0
    @collection_view = subview(CollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.alwaysBounceVertical = true

    @collection_view.registerClass(FollowingCell, forCellWithReuseIdentifier:FOLLOWING_IDENTIFIER)
  end

  def init
    super
    reload
    self
  end

  def dealloc
    @query.connection.cancel if @query
    super
  end

  def viewDidLoad
    super
    add_title_to_nav_bar "Following Friends"
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

  def on_done
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def numberOfSectionsInCollectionView(collectionView)
    1
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    @users ? @users.count : 0
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    [306,45]
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    [10,0,10,0]
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    cell = collectionView.dequeueReusableCellWithReuseIdentifier(FOLLOWING_IDENTIFIER, forIndexPath:indexPath)
    cell.user = @users[indexPath.item]
    cell
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    profile_vc = ProfileVC.new @users[indexPath.item]
    self.navigationController.pushViewController(profile_vc, animated:true)
  end
end
