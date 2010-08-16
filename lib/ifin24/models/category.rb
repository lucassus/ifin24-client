class Ifin24::Models::Category < Ifin24::Models::Base

  attr_accessor :id, :name
  attr_accessor :children

  def to_s
    @name
  end

end
