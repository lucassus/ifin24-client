# encoding: utf-8

class Ifin24::Commands::ListEntries < Ifin24::Commands::Base

  def execute
    current_page = 1
    list, pages = @client.fetch_entries(current_page)
    print_entries(list)

    console_menu('Powrót do głównego menu') do |menu|
      menu.choice("Poprzednia strona") do
        current_page -= 1 if current_page > 1

        list, pages = @client.fetch_entries(current_page)
        print_entries(list)
      end

      menu.choice("Następna strona") do
        current_page += 1 if current_page < pages

        list, pages = @client.fetch_entries(current_page)
        print_entries(list)
      end
    end
  end

  private

  def print_entries(list)
    print_list(list, :date, :title, :sub_category, :tags, :amount)
  end

end
