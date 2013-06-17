class SpotVC < UIViewController
  include NavigationHelpers

  MAP_CELL_IDENTIFIER = "MAP_CELL_IDENTIFIER"
  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"
  ANSWER_CELL_IDENTIFIER = "ANSWER_CELL_IDENTIFIER"
  SOCIAL_CELL_IDENTIFIER = "SOCIAL_CELL_IDENTIFIER"

  MAP_CELL_SECTION = 0
  ANSWER_CELL_SECTION = 1
  SOCIAL_CELL_SECTION = 2

  stylesheet :spot_vc

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    @collection_view = subview(UICollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.registerClass(MapCell, forCellWithReuseIdentifier:MAP_CELL_IDENTIFIER)
    @collection_view.registerClass(AnswerCell, forCellWithReuseIdentifier:ANSWER_CELL_IDENTIFIER)
    @collection_view.registerClass(SocialCell, forCellWithReuseIdentifier:SOCIAL_CELL_IDENTIFIER)
    @collection_view.alwaysBounceVertical = true
  end

  attr_accessor :spot

  def initWithSpot(spot)
    init
    self.spot = spot
    self.hidesBottomBarWhenPushed = true
    reload
    self
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar

    add_right_nav_button "Find It", self, :on_find_it unless self.spot.unlocked
  end

  def on_find_it
    source = BW::Device.camera.rear || BW::Device.camera.any
    source.picture(media_types: [:image], allows_editing: true) do |result|
      unless result[:error]
        edited_image = result[:edited_image]
        # upload this thing.
        SVProgressHUD.show
        Answer.submit(self.spot, edited_image) do |response, json|
          SVProgressHUD.dismiss
          if response.ok?
            answer = Answer.merge_or_insert(json)
            self.spot.answers << answer
            self.spot.unlocked = true
            self.navigationItem.rightBarButtonItem = nil
            @collection_view.reloadData if @collection_view
          else
          end
        end
      end
    end if source
  end

  def update_find_it_button(location)
    return unless self.navigationItem.rightBarButtonItem
    distance = location.distanceFromLocation(CLLocation.alloc.initWithLatitude(self.spot.latitude, longitude:self.spot.longitude))
    self.navigationItem.rightBarButtonItem.enabled = distance < 50
  end

  def reload
    Spot.for self.spot.id do |response, spot|
      self.spot = spot if response.ok?
      @collection_view.reloadData if @collection_view
    end
  end

  def numberOfSectionsInCollectionView(collectionView)
    3
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    case section
    when MAP_CELL_SECTION
      [10,0,5,0]
    when ANSWER_CELL_SECTION
      [0,7,0,7]
    when SOCIAL_CELL_SECTION
      [0,7,0,7]
    else
      [0,0,0,0]
    end
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when MAP_CELL_SECTION
      1
    when ANSWER_CELL_SECTION
      self.spot.answers ? self.spot.answers.count : 0
    when SOCIAL_CELL_SECTION
      self.spot.unlocked ? 0 : 1
    else
      0
    end
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    case indexPath.section
    when MAP_CELL_SECTION
      [306,175]
    when ANSWER_CELL_SECTION
      [150,200]
    when SOCIAL_CELL_SECTION
      [306,50]
    else
      [0,0]
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when MAP_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(MAP_CELL_IDENTIFIER, forIndexPath:indexPath)


      annotation = SpotAnnotation.new self.spot

      cell.label.text = "\u201c#{annotation.title}\u201d"
      cell.map_view.region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
      cell.map_view.delegate = self
      cell.map_view.setUserInteractionEnabled(false)
      update_find_it_button(cell.map_view.userLocation.location)
      # don't re add annotations
      cell.map_view.addAnnotation(annotation) unless cell.map_view.annotations.count > 0
      cell
    when ANSWER_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(ANSWER_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.answer = @spot.answers.first if @spot.answers
      cell
    when SOCIAL_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(SOCIAL_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.user_image_view.set_image_from_url @spot.user.avatar_url_thumb if @spot.user
      cell.label.attributedText = @spot.user.username.bold(11) + " originally found this on #{@spot.created_at.to_s}. Find to unlock their photo!"
      cell
    else
      nil
    end
  end

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass(SpotAnnotation)
    cached = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER)
    annotation = cached || SpotAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    annotation.canShowCallout = false
    annotation.setSelected(true, animated:false)
    annotation
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location
    @collection_view.reloadData if @collection_view
  end

  def mapView(mapView, didUpdateUserLocation:userLocation)
    return unless userLocation.location
    update_find_it_button(userLocation.location)
  end

end
