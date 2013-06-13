class SpotVC < UIViewController

  attr_accessor :spot

  def initWithSpot(spot)
    init
    self.spot = spot
    reload
    self
  end


  def reload
    Spot.for self.spot.id do |response, spot|
      self.spot = spot if response.ok?
    end
  end

end
