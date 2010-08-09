class Category

  attr_accessor :id, :name
  attr_accessor :sub_categories

  def initialize(id, name, sub_categories = [])
    @id, @name = id, name
    @sub_categories = sub_categories
  end

end
