class UIImage
  def center_stretch
    self.stretchable([(self.size.height/2).floor-1,(self.size.width/2).floor-1,(self.size.height/2).floor, (self.size.width/2).floor])
  end
end
