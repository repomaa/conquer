class Numeric
  def hours
    self * 60.minutes
  end

  def minutes
    self * 60.seconds
  end

  def seconds
    self
  end

  def milliseconds
    self.to_f / 1000
  end
end
