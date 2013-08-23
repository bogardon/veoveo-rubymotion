class ConnectVC < UIViewController
  include ViewControllerHelpers
  stylesheet :connect_vc

  PROMPT_CELL_IDENTIFIER = "PROMPT_CELL_IDENTIFIER"
  CONNECT_CELL_IDENTIFIER = "CONNECT_CELL_IDENTIFIER"
  ACTION_CELL_IDENTIFIER = "ACTION_CELL_IDENTIFIER"

  PROMPT_SECTION = 0
  CONNECT_SECTION = 1
  ACTION_SECTION = 2

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    @collection_view = subview(UICollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.registerClass(PromptCell, forCellWithReuseIdentifier:PROMPT_CELL_IDENTIFIER)
    @collection_view.registerClass(ConnectCell, forCellWithReuseIdentifier:CONNECT_CELL_IDENTIFIER)
    @collection_view.registerClass(ActionCell, forCellWithReuseIdentifier:ACTION_CELL_IDENTIFIER)
    @collection_view.alwaysBounceVertical = true
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
  end

  def numberOfSectionsInCollectionView(collectionView)
    3
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    case section
    when PROMPT_SECTION
      [7,0,0,0]
    when CONNECT_SECTION
      [0,0,0,0]
    when ACTION_SECTION
      [0,0,0,0]
    else
      [0,0,0,0]
    end
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when PROMPT_SECTION
      1
    when CONNECT_SECTION
      1 # only facebook for now
    when ACTION_SECTION
      1
    else
      0
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    case indexPath.section
    when PROMPT_SECTION
      [306, 44]
    when CONNECT_SECTION
      [306, 44] # only facebook for now
    when ACTION_SECTION
      [306, 44]
    else
      0
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when PROMPT_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(PROMPT_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.label.text = "2. Find Friends to Follow"
      cell
    when CONNECT_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(CONNECT_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell
    when ACTION_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(ACTION_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.label.text = "Done"
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    collectionView.deselectItemAtIndexPath(indexPath, animated:true)
    case indexPath.section
    when CONNECT_SECTION
      if Facebook.is_open?
        self.navigationController.pushViewController(FindFriendsVC.alloc.init, animated:true)
      else
        show_hud
        Facebook.connect true do |response, json|
          hide_hud response.ok?
          if response.ok?
            self.navigationController.pushViewController(FindFriendsVC.alloc.init, animated:true)
          end
        end
      end
    when ACTION_SECTION
      dismissViewControllerAnimated(true, completion:nil)
    end
  end

end
