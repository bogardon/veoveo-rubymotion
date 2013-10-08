class SettingsVC < UIViewController
  include ViewControllerHelpers

  FACEBOOK_CELL_IDENTIFIER = "FACEBOOK_CELL_IDENTIFIER"
  LOGOUT_CELL_IDENTIFIER = "LOGOUT_CELL_IDENTIFIER"
  SWITCH_CELL_IDENTIFIER = "SWITCH_CELL_IDENTIFIER"
  HEADER_CELL_IDENTIFIER = "HEADER_CELL_IDENTIFIER"
  PUSH_HEADER_CELL_IDENTIFIER = "PUSH_HEADER_CELL_IDENTIFIER"
  PUSH_CELL_IDENTIFIER = "PUSH_CELL_IDENTIFIER"

  SPOT_ANSWERED_SECTION = 0
  SPOTS_NEARBY_SECTION = 1
  FOLLOWED_SECTION = 2
  FACEBOOK_SECTION = 3
  LOGOUT_SECTION = 4

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

    @collection_view.registerClass(SwitchCell, forCellWithReuseIdentifier:FACEBOOK_CELL_IDENTIFIER)
    @collection_view.registerClass(LogoutCell, forCellWithReuseIdentifier:LOGOUT_CELL_IDENTIFIER)
    @collection_view.registerClass(PushHeaderCell, forCellWithReuseIdentifier:PUSH_HEADER_CELL_IDENTIFIER)
    @collection_view.registerClass(PushCell, forCellWithReuseIdentifier:PUSH_CELL_IDENTIFIER)
    @collection_view.registerClass(HeaderCell, forSupplementaryViewOfKind:UICollectionElementKindSectionHeader, withReuseIdentifier:HEADER_CELL_IDENTIFIER)


    background = "bg.png".uiimageview
    background.contentMode = UIViewContentModeScaleAspectFill

    @collection_view.backgroundView = background
    self.view.addSubview(@collection_view)

    @titles = {
      SPOT_ANSWERED_SECTION => {
        0 => "When someone finds my discovery:",
        1 => "Anyone",
        2 => "People I Follow",
        3 => "No One"
      },
      SPOTS_NEARBY_SECTION => {
        0 => "When I'm near a discovery by:",
        1 => "Anyone",
        2 => "People I Follow",
        3 => "No One"
      },
      FOLLOWED_SECTION => {
        0 => "When someone follows me:",
        1 => "Anyone",
        2 => "My Facebook Friends",
        3 => "No One"
      }
    }

    @get_selectors = {
      SPOT_ANSWERED_SECTION => :spot_answered_push,
      SPOTS_NEARBY_SECTION => :spots_nearby_push,
      FOLLOWED_SECTION => :followed_push
    }

    @patch_selectors = {
      SPOT_ANSWERED_SECTION => :patch_spot_answered_push,
      SPOTS_NEARBY_SECTION => :patch_spots_nearby_push,
      FOLLOWED_SECTION => :patch_followed_push
    }

    @push_values = {
      1 => "anyone",
      2 => "followed",
      3 => "noone"
    }
  end

  def viewDidLoad
    super
    add_title_to_nav_bar "Settings"
  end

  def on_facebook
    self.show_hud
    if Facebook.is_open?
      Facebook.unlink do |response, json|
        self.hide_hud response.ok?
        @collection_view.reloadData
      end
    else
      Facebook.connect true do |response, json|
        self.hide_hud response.ok?
        @collection_view.reloadData
      end
    end
  end

  def numberOfSectionsInCollectionView(collectionView)
    5
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when SPOT_ANSWERED_SECTION
      4
    when SPOTS_NEARBY_SECTION
      4
    when FOLLOWED_SECTION
      4
    when FACEBOOK_SECTION
      1
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
    else
      [306, 40]
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

      label_text = @titles[indexPath.section][indexPath.item]

      case indexPath.item
      when 0
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(PUSH_HEADER_CELL_IDENTIFIER, forIndexPath:indexPath)
        cell.label.text = label_text
        cell
      else
        cell = collectionView.dequeueReusableCellWithReuseIdentifier(PUSH_CELL_IDENTIFIER, forIndexPath: indexPath)
        cell.label.text = label_text
        cell.selected = case indexPath.item
        when 1
          User.current.send(@get_selectors[indexPath.section]) == "anyone"
        when 2
          User.current.send(@get_selectors[indexPath.section]) == "followed"
        when 3
          User.current.send(@get_selectors[indexPath.section]) == "noone"
        end
        cell
      end
    when FACEBOOK_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(FACEBOOK_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.label.text = "Facebook"
      cell.switch.on = Facebook.is_open?

      unless cell.switch.allTargets.count > 0
        cell.switch.addTarget(self, action: :on_facebook, forControlEvents:UIControlEventValueChanged)
      end

      cell
    when LOGOUT_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(LOGOUT_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    case indexPath.section
    when SPOT_ANSWERED_SECTION, SPOTS_NEARBY_SECTION, FOLLOWED_SECTION
      return if indexPath.item == 0
      User.send(@patch_selectors[indexPath.section], @push_values[indexPath.item])
      @collection_view.reloadData
    when LOGOUT_SECTION
      collectionView.deselectItemAtIndexPath(indexPath, animated:true)
      User.current = nil
    end
  end
end
