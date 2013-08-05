class FeedVC < UIViewController
  include ViewControllerHelpers
  stylesheet :feed_vc

  ANSWER_FEED_CELL_IDENTIFIER = "ANSWER_FEED_CELL_IDENTIFIER"

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    flow.minimumLineSpacing = 0
    @collection_view = subview(CollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.alwaysBounceVertical = true

    @collection_view.registerClass(AnswerFeedCell, forCellWithReuseIdentifier:ANSWER_FEED_CELL_IDENTIFIER)
  end

  def init
    super
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:CurrentUserDidLoginNotification, object:nil)
    NSNotificationCenter.defaultCenter.addObserver(self, selector: :reload, name:CurrentUserDidUpdateFollowedUsers, object:nil)
    reload
    self
  end

  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    @query.connection.cancel if @query
    super
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar

    add_right_nav_button "Find Friends", self, :on_find_friends

    @refresh = UIRefreshControl.alloc.init
    @refresh.addTarget(self, action: :reload, forControlEvents:UIControlEventValueChanged)
    @collection_view.addSubview(@refresh)
  end

  def on_find_friends
    self.presentViewController(UINavigationController.alloc.initWithRootViewController(ConnectVC.alloc.init), animated:true, completion:nil)
  end

  def reload
    return unless User.current
    @query.connection.cancel if @query
    @query = Answer.get_feed do |response, answers|
      if response.ok?
        @answers = answers
        @collection_view.reloadData if @collection_view
      end
      @refresh.endRefreshing if @refresh
    end
  end

  def numberOfSectionsInCollectionView(collectionView)
    1
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    @answers ? @answers.count : 0
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    [306,60]
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    [10,0,10,0]
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    cell = collectionView.dequeueReusableCellWithReuseIdentifier(ANSWER_FEED_CELL_IDENTIFIER, forIndexPath:indexPath)
    cell.image_button.tag = indexPath.item

    cell.image_button.removeTarget(self, action: "on_profile:", forControlEvents:UIControlEventTouchUpInside)
    cell.image_button.addTarget(self, action: "on_profile:", forControlEvents:UIControlEventTouchUpInside)

    cell.answer = @answers[indexPath.item]
    cell
  end

  def on_profile(sender)
    user = @answers[sender.tag].user
    profile_vc = ProfileVC.new user
    self.navigationController.pushViewController(profile_vc, animated:true)
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    spot_vc = SpotVC.alloc.initWithSpot @answers[indexPath.item].spot
    self.navigationController.pushViewController(spot_vc, animated:true)
  end

end
