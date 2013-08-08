class SettingsVC < UIViewController
  include ViewControllerHelpers
  stylesheet :settings_vc

  LOGOUT_CELL_IDENTIFIER = "LOGOUT_CELL_IDENTIFIER"
  SWITCH_CELL_IDENTIFIER = "SWITCH_CELL_IDENTIFIER"
  HEADER_CELL_IDENTIFIER = "HEADER_CELL_IDENTIFIER"

  NOTIFICATION_SECTION = 0
  LOGOUT_SECTION = 1

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    flow.minimumLineSpacing = 0
    @collection_view = subview(CollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.alwaysBounceVertical = true
    @collection_view.registerClass(LogoutCell, forCellWithReuseIdentifier:LOGOUT_CELL_IDENTIFIER)
    @collection_view.registerClass(SwitchCell, forCellWithReuseIdentifier:SWITCH_CELL_IDENTIFIER)
    @collection_view.registerClass(HeaderCell, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier:HEADER_CELL_IDENTIFIER)
  end

  def viewDidLoad
    super
    add_title_to_nav_bar "Settings"
  end

  def on_switch(sender)
    case sender.tag
    when 0
      User.patch_spot_answered sender.isOn do |response, json|
        @collection_view.reloadData
      end
    when 1
      User.patch_spots_nearby sender.isOn do |response, json|
        @collection_view.reloadData
      end
    end
  end

  def numberOfSectionsInCollectionView(collectionView)
    2
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when NOTIFICATION_SECTION
      2
    when LOGOUT_SECTION
      1
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    [10,0,0,0]
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    case indexPath.section
    when NOTIFICATION_SECTION
      [306,40]
    when LOGOUT_SECTION
      [306,44]
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, referenceSizeForHeaderInSection:section)
    case section
    when NOTIFICATION_SECTION
      [320, 30]
    else
      [0, 0]
    end
  end

  def collectionView(collectionView, viewForSupplementaryElementOfKind:kind, atIndexPath:indexPath)
    case indexPath.section
    when NOTIFICATION_SECTION
      collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:HEADER_CELL_IDENTIFIER, forIndexPath:indexPath)
    else
      nil
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when NOTIFICATION_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(SWITCH_CELL_IDENTIFIER, forIndexPath:indexPath)
      unless cell.switch.allTargets.count > 0
        cell.switch.addTarget(self, action: :"on_switch:", forControlEvents:UIControlEventValueChanged)
      end

      cell.switch.tag = indexPath.item

      cell.label.text = case indexPath.item
      when 0
        "someone found your spot"
      when 1
        "friends spots are nearby"
      end
      cell.switch.on = case indexPath.item
      when 0
        User.current.spot_answered_push_enabled
      when 1
        User.current.spots_nearby_push_enabled
      end
      cell
    when LOGOUT_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(LOGOUT_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    return unless indexPath.section == LOGOUT_SECTION
    collectionView.deselectItemAtIndexPath(indexPath, animated:true)
    User.current = nil
  end

end
