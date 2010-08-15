module Ifin24::Models
  class Category

    attr_accessor :id, :name
    attr_accessor :children

    def initialize(id, name, children = [])
      @id, @name = id, name
      @children = children
    end

    def to_s
      @name
    end

  end
end
