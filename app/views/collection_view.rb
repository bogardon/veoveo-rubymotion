class CollectionView < UICollectionView

  def layoutSubviews
    super
    self.subviews.each do |subview|
      next unless subview.is_a?(FeedCell)
      cell = subview
      indexPath = self.indexPathForCell(cell)
      next unless indexPath
      numberOfItems = self.numberOfItemsInSection(indexPath.section)
      cell.position = numberOfItems > 1 ? (indexPath.item == 0 ? FeedCell::POSITION_TOP : (indexPath.item == numberOfItems - 1 ? FeedCell::POSITION_BOT : FeedCell::POSITION_MID)) : FeedCell::POSITION_FULL
    end
  end

end


