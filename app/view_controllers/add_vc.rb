class AddVC < UIViewController
  include ViewControllerHelpers

  HINT_CELL_SECTION = 0
  HINT_CELL_IDENTIFIER = "HINT_CELL_IDENTIFIER"

  PHOTO_CELL_SECTION = 1
  PHOTO_CELL_IDENTIFIER = "PHOTO_CELL_IDENTIFIER"

  ACTION_CELL_SECTION = 2
  ACTION_CELL_IDENTIFIER = "ACTION_CELL_IDENTIFIER"

  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"

  def init
    super
    @did_auto_center = false
    self
  end

  def loadView
    super
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    @collection_view = UICollectionView.alloc.initWithFrame(self.view.bounds, collectionViewLayout:flow)
    @collection_view.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth
    @collection_view.delegate = self
    @collection_view.dataSource = self
    @collection_view.alwaysBounceVertical = true
    @collection_view.registerClass(HintCell, forCellWithReuseIdentifier:HINT_CELL_IDENTIFIER)
    @collection_view.registerClass(PhotoCell, forCellWithReuseIdentifier:PHOTO_CELL_IDENTIFIER)
    @collection_view.registerClass(ActionCell, forCellWithReuseIdentifier:ACTION_CELL_IDENTIFIER)

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
  end

  def on_add
    return unless @photo && @form && @form.text && @form.text.length > 0 && @spot
    @form.resignFirstResponder
    self.show_hud

    Spot.add_new(@form.text, @spot.latitude, @spot.longitude, @photo) do |response, spot|
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
    3
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    case section
    when HINT_CELL_SECTION
      [7,7,0,7]
    when PHOTO_CELL_SECTION
      [0,7,0,7]
    when ACTION_CELL_SECTION
      [0,7,7,7]
    else
      [0,0,0,0]
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
    else
      0
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
    else
      [0,0]
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when HINT_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(HINT_CELL_IDENTIFIER, forIndexPath:indexPath)
      @form = cell.form
      @form.becomeFirstResponder
      cell.map_view.delegate = self
      cell.map_view.showsUserLocation = true
      cell
    when PHOTO_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(PHOTO_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.backgroundView = UIImageView.alloc.initWithImage(@photo)
      cell
    when ACTION_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(ACTION_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.label.text = @photo ? "Change Photo" : "Take a Photo"
      cell
    else
      nil
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

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.is_a?(Spot)
    cached = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER)
    view = cached || MKAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    view.image = "found_pin_selected.png".uiimage
    view.centerOffset = [0, -18]
    view.draggable = true
    view.setSelected(true, animated:false)
    view.canShowCallout = false
    view
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location && userLocation.location.coordinate && !@did_auto_center
    @did_auto_center = true
    coordinate = userLocation.location.coordinate
    region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
    mapView.setRegion(region)
    json = {'id' => -1, "unlocked" => true, "latitude" => coordinate.latitude, "longitude" => coordinate.longitude}
    @spot = Spot.new json
    mapView.addAnnotation(@spot)
  end

  def mapView(mapView, annotationView:annotationView, didChangeDragState:newState, fromOldState:oldState)
  end

end
