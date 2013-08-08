class SettingsVC < UIViewController
  include ViewControllerHelpers
  stylesheet :settings_vc

  LOGOUT_CELL_IDENTIFIER = "LOGOUT_CELL_IDENTIFIER"

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    flow.minimumLineSpacing = 0
    @collection_view = subview(CollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.alwaysBounceVertical = true
    @collection_view.registerClass(LogoutCell, forCellWithReuseIdentifier:LOGOUT_CELL_IDENTIFIER)

  end

  def viewDidLoad
    super
    add_title_to_nav_bar "Settings"
  end

  def numberOfSectionsInCollectionView(collectionView)
    1
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    1
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    [10,0,0,0]
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    [306,44]
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    cell = collectionView.dequeueReusableCellWithReuseIdentifier(LOGOUT_CELL_IDENTIFIER, forIndexPath:indexPath)
    cell
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    collectionView.deselectItemAtIndexPath(indexPath, animated:true)
    User.current = nil
  end

end
