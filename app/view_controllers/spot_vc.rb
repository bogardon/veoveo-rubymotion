class SpotVC < UIViewController
  include NavigationHelpers

  MAP_CELL_IDENTIFIER = "MAP_CELL_IDENTIFIER"
  SPOT_ANNOTATION_IDENTIFIER = "SPOT_ANNOTATION_IDENTIFIER"
  ANSWER_CELL_IDENTIFIER = "ANSWER_CELL_IDENTIFIER"

  stylesheet :spot_vc

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    @collection_view = subview(UICollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.registerClass(MapCell, forCellWithReuseIdentifier:MAP_CELL_IDENTIFIER)
    @collection_view.registerClass(AnswerCell, forCellWithReuseIdentifier:ANSWER_CELL_IDENTIFIER)
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
  end

  def reload
    Spot.for self.spot.id do |response, spot|
      self.spot = spot if response.ok?
      @collection_view.reloadData if @collection_view
    end
  end

  def numberOfSectionsInCollectionView(collectionView)
    2
  end

  def collectionView(collectionView, layout:collectionViewLayout, insetForSectionAtIndex:section)
    section > 0 ? [5,7,0,7] : [10,0,0,0]
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    section > 0 ? (self.spot.answers ? self.spot.answers.count : 0) : 1
  end

  def collectionView(collectionView, layout:collectionViewLayout, sizeForItemAtIndexPath:indexPath)
    indexPath.section > 0 ? [150,200] : [306,175]
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when 0
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(MAP_CELL_IDENTIFIER, forIndexPath:indexPath)

      spot_proxy = SpotProxy.alloc.init
      spot_proxy.spot = @spot

      cell.label.text = "\u201c#{spot_proxy.title}\u201d"
      cell.map_view.region = MKCoordinateRegionMakeWithDistance(spot_proxy.coordinate, 200, 200)
      cell.map_view.delegate = self
      cell.map_view.setUserInteractionEnabled(false)

      # don't re add annotations
      cell.map_view.addAnnotation(spot_proxy) unless cell.map_view.annotations.count > 0
      cell
    when 1
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(ANSWER_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.answer = @spot.answers.first if @spot.answers
      cell
    else
      nil
    end
  end

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass(SpotProxy)
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

end
