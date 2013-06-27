class AddVC < UIViewController
  include ViewControllerHelpers
  stylesheet :add_vc

  attr_accessor :location
  attr_accessor :completion

  HINT_CELL_SECTION = 0
  HINT_CELL_IDENTIFIER = "HINT_CELL_IDENTIFIER"

  PHOTO_CELL_SECTION = 1
  PHOTO_CELL_IDENTIFIER = "PHOTO_CELL_IDENTIFIER"

  ACTION_CELL_SECTION = 2
  ACTION_CELL_IDENTIFIER = "ACTION_CELL_IDENTIFIER"

  layout do
    subview(UIImageView, :background)
    flow = UICollectionViewFlowLayout.alloc.init
    flow.minimumInteritemSpacing = 0
    @collection_view = subview(UICollectionView.alloc.initWithFrame(CGRectZero, collectionViewLayout:flow), :collection_view, delegate:self, dataSource:self)
    @collection_view.alwaysBounceVertical = true
    @collection_view.registerClass(HintCell, forCellWithReuseIdentifier:HINT_CELL_IDENTIFIER)
    @collection_view.registerClass(PhotoCell, forCellWithReuseIdentifier:PHOTO_CELL_IDENTIFIER)
    @collection_view.registerClass(ActionCell, forCellWithReuseIdentifier:ACTION_CELL_IDENTIFIER)

  end

  def viewDidLoad
    super
    add_logo_to_nav_bar
    add_right_nav_button "Add", self, :on_add
    add_left_nav_button "Cancel", self, :on_cancel
  end

  def on_add
    return unless @photo && @form && @form.text && @form.text.length > 0
    self.show_hud
    Spot.add_new(@form.text, @location, @photo) do |response, json|
      self.hide_hud response.ok?
      if response.ok?
        @completion.call(Spot.merge_or_insert(json))
        @completion = nil
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
      [10,7,0,7]
    when PHOTO_CELL_SECTION
      [0,7,0,7]
    when ACTION_CELL_SECTION
      [0,7,0,7]
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
      [306,44]
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

end
