class Ifin24::Models::Category < Ifin24::Models::Base

  attr_accessor :id, :name
  attr_accessor :children

  def initialize(attributes = {})
    super(attributes)
    @children = []
  end

  def to_s
    @name
  end

end
