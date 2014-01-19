class OnboardWindow < UIWindow
  attr_accessor :on_dismiss
  attr_accessor :spot_user

  CELL_IDENTIFIER = "CELL_IDENTIFIER"

  def init
    super
    self.frame = UIScreen.mainScreen.bounds
    self.backgroundColor = UIColor.clearColor

    dim = UIView.alloc.initWithFrame(self.bounds)
    dim.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth
    dim.backgroundColor = UIColor.blackColor
    dim.alpha = 0.7
    self.addSubview(dim)

    container = UIView.alloc.initWithFrame [[35,100],[250,290]]
    container.backgroundColor = UIColor.colorWithRed(238.0/255.0, green:238.0/255.0, blue:238.0/255.0, alpha:1.0)
    container.layer.cornerRadius = 10
    container.layer.shadowOpacity = 0.9
    container.layer.shadowRadius = 3
    container.layer.masksToBounds = false
    container.layer.shadowOffset = [0,1]
    container.layer.shadowColor = UIColor.blackColor.CGColor

    self.addSubview(container)

    flow_layout = UICollectionViewFlowLayout.alloc.init
    flow_layout.scrollDirection = UICollectionViewScrollDirectionHorizontal
    flow_layout.minimumInteritemSpacing = 0
    flow_layout.minimumLineSpacing = 0

    @collection_view = UICollectionView.alloc.initWithFrame(container.bounds, collectionViewLayout:flow_layout)
    @collection_view.showsHorizontalScrollIndicator = false
    @collection_view.showsVerticalScrollIndicator = false
    @collection_view.delegate = self
    @collection_view.dataSource = self
    @collection_view.registerClass(OnboardCell, forCellWithReuseIdentifier:CELL_IDENTIFIER)
    @collection_view.backgroundColor = UIColor.clearColor
    @collection_view.setPagingEnabled(true)
    container.addSubview(@collection_view)

    @page_control = UIPageControl.alloc.init
    @page_control.numberOfPages = 3
    @page_control.currentPage = 0
    @page_control.pageIndicatorTintColor = UIColor.colorWithRed(216.0/255.0, green:216.0/255.0, blue:216.0/255.0, alpha:1.0)
    @page_control.currentPageIndicatorTintColor = UIColor.colorWithRed(168.0/255.0, green:168.0/255.0, blue:168.0/255.0, alpha:1.0)

    @page_control.frame = [[0,200],[container.frame.size.width, 20]]
    container.addSubview(@page_control)

    @button = UIButton.alloc.initWithFrame [[10, 230], [230, 50]]
    @button.setBackgroundImage("primary_button.png".uiimage.stretchable([22,22,21,21]), forState:UIControlStateNormal)
    @button.setBackgroundImage("primarybutton_down.png".uiimage.stretchable([22,22,21,21]), forState:UIControlStateHighlighted)
    @button.setTitleColor(UIColor.whiteColor, forState:UIControlStateNormal)
    @button.titleLabel.font = UIFont.boldSystemFontOfSize(20)
    @button.setTitle("Got It!", forState:UIControlStateNormal)
    container.addSubview(@button)

    @button.addTarget(self, action: :on_button, forControlEvents:UIControlEventTouchUpInside)


    self
  end

  def on_button
    index_path = @collection_view.indexPathsForVisibleItems.first
    case index_path.item
    when 0
      @collection_view.scrollToItemAtIndexPath([0, 1].nsindexpath, atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally, animated:true)
    when 1
      @collection_view.scrollToItemAtIndexPath([0, 2].nsindexpath, atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally, animated:true)
    when 2
      @on_dismiss.call if @on_dismiss
      @on_dismiss = nil
    else
    end
  end

  def scrollViewDidScroll(scroll_view)
    @page_control.currentPage = (scroll_view.contentOffset.x/scroll_view.frame.size.width).floor
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELL_IDENTIFIER, forIndexPath:indexPath)

    cell.label.text = case indexPath.item
    when 0
      "Take a photo to see all the photos for this discovery."
    when 1
      "You'll be able to see if you found the same thing."
    when 2
      "We'll notify them with your photo to show you found it!"
    else
      ""
    end

    image = case indexPath.item
    when 0
      "onboarding_camera.png".uiimage
    when 1
      "onboarding_picture.png".uiimage
    when 2
      "avatar.png".uiimage
    else
    end

    y_origin = case indexPath.item
    when 0
      125
    when 1
      120
    when 2
      110
    else
      120
    end

    cell.image_view.frame = [[(cell.contentView.frame.size.width/2-image.size.width/2).floor, y_origin], image.size]
    cell.image_view.image = image

    cell.image_view.layer.borderWidth = case indexPath.item
    when 2
      0.5
    else
      0
    end

    cell.image_view.layer.cornerRadius = case indexPath.item
    when 2
      image.size.width/2
    else
      0
    end

    cell.image_view.query.connection.cancel if cell.image_view.query
    if indexPath.item == 2
      cell.image_view.set_image_from_url self.spot_user.avatar_url_full, image
    end

    cell
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    collectionView.bounds.size
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    3
  end

end
