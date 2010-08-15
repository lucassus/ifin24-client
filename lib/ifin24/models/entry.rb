module Ifin24::Models
  class Entry

    # TODO Add validations
    attr_accessor :title, :date, :amount, :tags, :note
    attr_accessor :account
    
    attr_accessor :category
    attr_accessor :sub_category

    def category_full_name
      "#{category.name} | #{sub_category.name}"
    end

  end
end
