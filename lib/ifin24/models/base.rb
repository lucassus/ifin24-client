class Ifin24::Models::Base

  def initialize(attributes = {})
    attributes.each do |key, value|
      send(:"#{key}=", value)
    end
  end
  
end
