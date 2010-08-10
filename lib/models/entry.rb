class Entry

  # TODO Add validations
  attr_accessor :title, :date, :amount, :tags, :note
  attr_accessor :account_id, :account_name
  attr_accessor :category_name
  attr_accessor :subcategory_id, :subcategory_name

  def to_s
    result = ""
    delimiter = ("=" * 16) + "\n"
    
    result << delimiter
    result <<  "Nazwa: #{title}\n"
    result <<  "Data: #{date}\n"
    result <<  "Rachunek: #{account_name}\n"
    result <<  "Kwota: #{amount}\n"
    result <<  "Kategoria: #{category_full_name}\n"
    result <<  "Tagi: #{tags}\n"
    result <<  "Opis: #{note}\n"
    result << delimiter

    return result
  end

  def category_full_name
    "#{category_name} / #{subcategory_name}"
  end

end
