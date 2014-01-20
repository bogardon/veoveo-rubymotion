class AddVC < UIViewController
  include ViewControllerHelpers

  HINT_CELL_SECTION = 0
  HINT_CELL_IDENTIFIER = "HINT_CELL_IDENTIFIER"

  PHOTO_CELL_SECTION = 1
  PHOTO_CELL_IDENTIFIER = "PHOTO_CELL_IDENTIFIER"

  ACTION_CELL_SECTION = 2
  ACTION_CELL_IDENTIFIER = "ACTION_CELL_IDENTIFIER"

  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"

  EDUCATION_CELL_SECTION = 3
  EDUCATION_HEADER_CELL_IDENTIFIER = "EDUCATION_HEADER_CELL_IDENTIFIER"
  EDUCATION_CELL_IDENTIFIER = "EDUCATION_CELL_IDENTIFIER"

  def init
    super
    @did_auto_center = false
    self
  end

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
    @collection_view.registerClass(HintCell, forCellWithReuseIdentifier:HINT_CELL_IDENTIFIER)
    @collection_view.registerClass(PhotoCell, forCellWithReuseIdentifier:PHOTO_CELL_IDENTIFIER)
    @collection_view.registerClass(ActionCell, forCellWithReuseIdentifier:ACTION_CELL_IDENTIFIER)
    @collection_view.registerClass(PushHeaderCell, forCellWithReuseIdentifier:EDUCATION_HEADER_CELL_IDENTIFIER)
    @collection_view.registerClass(EducationCell, forCellWithReuseIdentifier:EDUCATION_CELL_IDENTIFIER)

    background = "bg.png".uiimageview
    background.contentMode = UIViewContentModeScaleAspectFill

    @collection_view.backgroundView = background
    self.view.addSubview(@collection_view)
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    add_right_nav_button "Add", self, :on_add
    add_left_nav_button "Cancel", self, :on_cancel

    @education_titles = {
      0 => "The best discoveries are:",
      1 => "Fun & Interesting",
      2 => "Stationary",
      3 => "Outdoors"
    }

    @education_images = {
      1 => "spaceship.png",
      2 => "stationary.png",
      3 => "outdoors.png"
    }
  end

  def on_add
    return unless @photo && @form && @form.text && @form.text.length > 0 && @pin && @map_view.userLocation.location
    @form.resignFirstResponder

    coordinate = @map_view.convertPoint(CGPointMake(@pin.center.x,@pin.center.y + 18), toCoordinateFromView:@pin.superview)
    self.show_hud

    Spot.add_new(@form.text, coordinate.latitude, coordinate.longitude, @photo) do |response, spot|
      self.hide_hud response.ok?
      if response.ok?
        self.dismissViewControllerAnimated(true, completion:nil)
      else
      end
    end
  end

  def on_cancel
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def on_take_photo
    source = BW::Device.camera.rear || BW::Device.camera.any
    source.picture(media_types: [:image], allows_editing: true) do |result|
      unless result[:error]
        @photo = result[:edited_image]
        @collection_view.reloadData
      end
    end if source
  end

  def numberOfSectionsInCollectionView(collectionView)
    4
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    case section
    when HINT_CELL_SECTION
      [7,7,0,7]
    when PHOTO_CELL_SECTION
      [0,7,0,7]
    when ACTION_CELL_SECTION
      [0,7,7,7]
    when EDUCATION_CELL_SECTION
      [0,7,7,7]
    end
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when HINT_CELL_SECTION
      1
    when PHOTO_CELL_SECTION
      @photo ? 1 : 0
    when ACTION_CELL_SECTION
      1
    when EDUCATION_CELL_SECTION
      4
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    case indexPath.section
    when HINT_CELL_SECTION
      [306,171]
    when PHOTO_CELL_SECTION
      [306,306]
    when ACTION_CELL_SECTION
      [306,44]
    when EDUCATION_CELL_SECTION
      case indexPath.item
      when 0
        [306, 40]
      else
        [306, 50]
      end
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when HINT_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(HINT_CELL_IDENTIFIER, forIndexPath:indexPath)
      @form = cell.form
      cell.map_view.delegate = self
      unless @map_view
        cell.map_view.showsUserLocation = true
      end
      @map_view = cell.map_view
      cell
    when PHOTO_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(PHOTO_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.photo.image = @photo
      cell
    when ACTION_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(ACTION_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.label.text = @photo ? "Change Photo" : "Take a Photo"
      cell
    when EDUCATION_CELL_SECTION
      cell = case indexPath.item
      when 0
        header = collectionView.dequeueReusableCellWithReuseIdentifier(EDUCATION_HEADER_CELL_IDENTIFIER, forIndexPath:indexPath)
        header
      else
        edu = collectionView.dequeueReusableCellWithReuseIdentifier(EDUCATION_CELL_IDENTIFIER, forIndexPath:indexPath)
        edu.image_view.image = @education_images[indexPath.item].uiimage
        edu
      end
      cell.label.text = @education_titles[indexPath.item]
      cell
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    collectionView.deselectItemAtIndexPath(indexPath, animated:true)
    case indexPath.section
    when ACTION_CELL_SECTION
      on_take_photo
    end
  end

  def scrollViewDidScroll(scrollView)
    @form.resignFirstResponder
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location && userLocation.location.coordinate && !@did_auto_center
    @did_auto_center = true
    coordinate = userLocation.location.coordinate
    region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
    mapView.setRegion(region)
    @pin = "found_pin_selected.png".uiimageview
    @pin.center = [(mapView.frame.size.width/2).floor,(mapView.frame.size.height/2-18).floor]
    mapView.addSubview(@pin)
    mapView.showsUserLocation = false
  end

end
