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
    @login_observer = App.notification_center.observe CurrentUserDidLoginNotification do |notification|
      return unless self.navigationController.viewControllers.first == self
      reload
    end
    @foreground_observer = App.notification_center.observe UIApplicationWillEnterForegroundNotification do |notification|
      reload
    end

    reload
    self
  end

  def dealloc
    App.notification_center.unobserve @login_observer
    App.notofication_center.unobserve @foreground_observer
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
  end

  def reload

    options = {:format => :json}
    VeoVeoAPI.get 'answers', options do |response, json|
      @answers = json.map do |data|
        Answer.merge_or_insert data
      end
      @collection_view.reloadData if @collection_view
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
    cell.image_button.when UIControlEventTouchUpInside do
      user = @answers[indexPath.item].user
      profile_vc = ProfileVC.new user
      self.navigationController.pushViewController(profile_vc, animated:true)
    end
    cell.answer = @answers[indexPath.item]
    cell
  end


  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    spot_vc = SpotVC.alloc.initWithSpot @answers[indexPath.item].spot
    self.navigationController.pushViewController(spot_vc, animated:true)
  end

end
