class Ifin24::Models::Limit < Ifin24::Models::Base

  attr_accessor :name
  attr_accessor :amount
  attr_accessor :max

  def initialize(attributes = {})
    super(attributes)
    @amount ||= 0
    @max ||= 0
  end

end
