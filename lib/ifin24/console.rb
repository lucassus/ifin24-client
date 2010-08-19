# encoding: utf-8

class Ifin24::Console
  include Ifin24::Helpers::Printer

  def initialize(client)
    @client = client
  end

  def main_menu
    catch :exit do
      loop do
        choose do |menu|
          menu.index = :letter
          menu.index_suffix = ") "

          menu.choice("Dodaj wydatek") { Ifin24::Commands::AddExpense.new(@client).execute }
          menu.choice("Lista kont") { list_accounts }
          menu.choice("Lista ostatnich transakcji") { list_entries }

          menu.choice("Koniec") { throw :exit }
        end
      end
    end
  end

  def list_accounts
    print_list(@client.accounts, :name)
  end

  def print_entries(list)
    print_list(list, :date, :title, :sub_category, :tags, :amount)
  end

  def list_entries
    current_page = 1
    list, pages = @client.fetch_entries(current_page)
    print_entries(list)

    catch :exit do
      loop do
        choose do |menu|
          menu.index = :letter
          menu.index_suffix = ") "

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

          menu.choice("Powrót do głównego menu") { throw :exit }
        end
      end
    end
  end

end
