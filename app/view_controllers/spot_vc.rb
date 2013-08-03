class SpotVC < UIViewController
  include ViewControllerHelpers

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
    reload
    self
  end

  def dealloc
    @query.connection.cancel if @query
    super
  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    @refresh = UIRefreshControl.alloc.init
    @refresh.addTarget(self, action: :reload, forControlEvents:UIControlEventValueChanged)
    @collection_view.addSubview(@refresh)
  end

  def on_delete
    alert = BW::UIAlertView.new(:title => "Really delete?", :message => "This cannot be undone.", :buttons => ["Delete", "Cancel"], :did_dismiss => (lambda do |alert|
      if alert.clicked_button.index == 0
        self.show_hud
        self.spot.delete do |response, json|
          self.hide_hud response.ok?
          if response.ok?
            self.navigationController.popViewControllerAnimated(true)
          end
        end
      end
    end))
    alert.show
  end

  def on_find_it
    return unless @map_view && @map_view.userLocation.location
    distance = @map_view.userLocation.location.distanceFromLocation(CLLocation.alloc.initWithLatitude(self.spot.latitude, longitude:self.spot.longitude))
    if distance < 50
      take_photo
    else
      alert = BW::UIAlertView.new(:title => "Too far away!", :message => "You must be within 50 meters to find this.", :buttons => "OK")
      alert.show
    end
  end

  def take_photo
    source = BW::Device.camera.rear || BW::Device.camera.any
    source.picture(media_types: [:image], allows_editing: true) do |result|
      unless result[:error]
        edited_image = result[:edited_image]
        # upload this thing.
        self.show_hud
        Answer.submit(self.spot, edited_image) do |response, json|
          self.hide_hud response.ok?
          if response.ok?
            answer = Answer.merge_or_insert(json)
            self.spot.answers.unshift(answer)
            self.spot.unlocked = true
            self.navigationItem.rightBarButtonItem = nil
            @collection_view.reloadData if @collection_view
          else
          end
        end
      end
    end if source
  end

  def reload
    @query.connection.cancel if @query
    @query = Spot.for self.spot.id do |response, spot|
      self.spot = spot if response.ok?
      @collection_view.reloadData if @collection_view
      @refresh.endRefreshing if @refresh
      add_right_nav_button "Find It", self, :on_find_it unless self.spot.unlocked
      add_right_nav_button "Delete", self, :on_delete if self.spot.user == User.current
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
      [0,7,25,7]
    else
      [0,0,0,0]
    end
  end

  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when MAP_CELL_SECTION
      self.spot.latitude && self.spot.longitude ? 1 : 0
    when ANSWER_CELL_SECTION
      self.spot.answers && self.spot.unlocked ? self.spot.answers.count : 0
    when SOCIAL_CELL_SECTION
      self.spot.unlocked.nil? || self.spot.unlocked ? 0 : 1
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

  def on_answer_image(button)
    cell = @collection_view.cellForItemAtIndexPath [ANSWER_CELL_SECTION, button.tag].nsindexpath

    vc = GGFullscreenImageViewController.alloc.init
    vc.liftedImageView = cell.answer_image_view
    self.presentViewController(vc, animated:true, completion:nil)
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    case indexPath.section
    when MAP_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(MAP_CELL_IDENTIFIER, forIndexPath:indexPath)


      annotation = self.spot

      cell.label.text = "\u201c#{annotation.title}\u201d"
      cell.map_view.region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 200, 200)
      cell.map_view.delegate = self
      cell.map_view.setUserInteractionEnabled(false)
      @map_view = cell.map_view
      # don't re add annotations
      cell.map_view.addAnnotation(annotation) unless cell.map_view.annotations.count > 0
      cell
    when ANSWER_CELL_SECTION

      cell = collectionView.dequeueReusableCellWithReuseIdentifier(ANSWER_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.image_button.tag = indexPath.item
      cell.image_button.removeTarget(self, action: "on_answer_image:", forControlEvents:UIControlEventTouchUpInside)
      cell.image_button.addTarget(self, action: "on_answer_image:", forControlEvents:UIControlEventTouchUpInside)

      cell.answer = @spot.answers[indexPath.item]
      cell
    when SOCIAL_CELL_SECTION
      cell = collectionView.dequeueReusableCellWithReuseIdentifier(SOCIAL_CELL_IDENTIFIER, forIndexPath:indexPath)
      cell.user_image_view.set_image_from_url @spot.user.avatar_url_thumb if @spot.user
      formatter = Time.cached_date_formatter("MMMM dd, YYYY")
      date_str = formatter.stringFromDate(@spot.created_at)
      cell.label.attributedText = @spot.user.username.bold(11) + " discovered this on #{date_str}. Find to unlock!" if @spot.user
      cell
    else
      nil
    end
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    case indexPath.section
    when ANSWER_CELL_SECTION
      profile_vc = ProfileVC.new @spot.answers[indexPath.item].user
      self.navigationController.pushViewController(profile_vc, animated:true)
    when SOCIAL_CELL_SECTION
      profile_vc = ProfileVC.new @spot.user
      self.navigationController.pushViewController(profile_vc, animated:true)
    else
    end
  end

  def mapView(mapView, viewForAnnotation:annotation)
    return nil unless annotation.isKindOfClass(Spot)
    cached = mapView.dequeueReusableAnnotationViewWithIdentifier(SPOT_ANNOTATION_IDENTIFIER)
    annotation = cached || SpotAnnotationView.alloc.initWithAnnotation(annotation, reuseIdentifier:SPOT_ANNOTATION_IDENTIFIER)
    annotation.canShowCallout = false
    annotation.setSelected(true, animated:false)
    annotation
  end
end
