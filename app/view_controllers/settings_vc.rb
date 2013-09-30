class SettingsVC < UIViewController
  include ViewControllerHelpers

  LOGOUT_CELL_IDENTIFIER = "LOGOUT_CELL_IDENTIFIER"
  SWITCH_CELL_IDENTIFIER = "SWITCH_CELL_IDENTIFIER"
  HEADER_CELL_IDENTIFIER = "HEADER_CELL_IDENTIFIER"
  NOTIFICATION_HEADER_CELL_IDENTIFIER = "NOTIFICATION_HEADER_CELL_IDENTIFIER"
  NOTIFICATION_CELL_IDENTIFIER = "NOTIFICATION_CELL_IDENTIFIER"

  SPOT_ANSWERED_SECTION = 0
  SPOTS_NEARBY_SECTION = 1
  FOLLOWED_SECTION = 2
  LOGOUT_SECTION = 3

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
    @collection_view.allowsMultipleSelection = true

    @collection_view.registerClass(LogoutCell, forCellWithReuseIdentifier:LOGOUT_CELL_IDENTIFIER)
    @collection_view.registerClass(NotificationHeaderCell, forCellWithReuseIdentifier:NOTIFICATION_HEADER_CELL_IDENTIFIER)
    @collection_view.registerClass(NotificationCell, forCellWithReuseIdentifier:NOTIFICATION_CELL_IDENTIFIER)
    @collection_view.registerClass(HeaderCell, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier:HEADER_CELL_IDENTIFIER)

    background = "bg.png".uiimageview
    background.contentMode = UIViewContentModeScaleAspectFill

    @collection_view.backgroundView = background
    self.view.addSubview(@collection_view)
  end

  def viewDidLoad
    super
    add_title_to_nav_bar "Settings"
  end

  def numberOfSectionsInCollectionView(collectionView)
    4
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when SPOT_ANSWERED_SECTION
      4
    when SPOTS_NEARBY_SECTION
      4
    when FOLLOWED_SECTION
      4
    when LOGOUT_SECTION
      1
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    case section
    when LOGOUT_SECTION
      [10,0,10,0]
    else
      [10,0,0,0]
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    case indexPath.section
    when SPOT_ANSWERED_SECTION, SPOTS_NEARBY_SECTION, FOLLOWED_SECTION
      indexPath.item == 0 ? [306,40] : [306, 50]
    when LOGOUT_SECTION
      [306,44]
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, referenceSizeForHeaderInSection:section)
    case section
    when SPOT_ANSWERED_SECTION
      [320, 30]
    else
      [0, 0]
    end
  end

  def collectionView(collectionView, viewForSupplementaryElementOfKind:kind, atIndexPath:indexPath)
    case indexPath.section
    when SPOT_ANSWERED_SECTION
      cell = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier:HEADER_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.label.text = "Notify Me"
      cell
    else
      nil
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when SPOT_ANSWERED_SECTION, SPOTS_NEARBY_SECTION, FOLLOWED_SECTION

      header_text = case indexPath.section
      when SPOT_ANSWERED_SECTION
        "When someone finds my discovery:"
      when SPOTS_NEARBY_SECTION
        "When I'm near a discovery by:"
      when FOLLOWED_SECTION
        "When someone follows me:"
      end

      notification_text = case indexPath.item
      when 1
        "Anyone"
      when 2
        "People I Follow"
      when 3
        "No One"
      end

      map = {
        SPOT_ANSWERED_SECTION => :spot_answered_push,
        SPOTS_NEARBY_SECTION => :spots_nearby_push,
        FOLLOWED_SECTION => :followed_push
      }

      selected = case indexPath.item
      when 1
        User.current.send(map[indexPath.section]) == "anyone"
      when 2
        User.current.send(map[indexPath.section]) == "followed"
      when 3
        User.current.send(map[indexPath.section]) == "noone"
      end

      case indexPath.item
      when 0
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(NOTIFICATION_HEADER_CELL_IDENTIFIER, forIndexPath:indexPath)
        cell.label.text = header_text
        cell
      else
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(NOTIFICATION_CELL_IDENTIFIER, forIndexPath: indexPath)
        cell.label.text = notification_text
        cell.selected = selected
        cell
      end
    when LOGOUT_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(LOGOUT_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    case indexPath.section
    when SPOT_ANSWERED_SECTION, SPOTS_NEARBY_SECTION, FOLLOWED_SECTION
      return if indexPath.item == 0

      val = case indexPath.item
      when 1
        "anyone"
      when 2
        "followed"
      when 3
        "noone"
      end

      selector = case indexPath.section
      when SPOT_ANSWERED_SECTION
        :patch_spot_answered_push
      when SPOTS_NEARBY_SECTION
        :patch_spots_nearby_push
      when FOLLOWED_SECTION
        :followed_push
      end

      User.send(selector, val )

      @collection_view.reloadData
    when LOGOUT_SECTION
      collectionView.deselectItemAtIndexPath(indexPath, animated:true)
      User.current = nil
    end
  end

end
