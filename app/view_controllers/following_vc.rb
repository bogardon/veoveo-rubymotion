class FollowingVC < UIViewController
  include ViewControllerHelpers
  stylesheet :following_vc

  attr_accessor :user

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

  def initialize(user)
    @user = user
    reload
  end

  def dealloc
    @query.connection.cancel if @query
    super
  end

  def viewDidLoad
    super
    add_title_to_nav_bar self.user.username
    @refresh = UIRefreshControl.alloc.init
    @refresh.when UIControlEventValueChanged do
      reload
    end
    @collection_view.addSubview(@refresh)
  end

  def reload
    @query.connection.cancel if @query
    @query = self.user.get_following do |response, users|
      @users = users
      @collection_view.reloadData if @collection_view
      @refresh.endRefreshing if @refresh
    end
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
