module Clock
  def self.today
    @today || Date.today
  end

  # For testing purposes
  def self.set_today(date)
    @today = date
  end
end
