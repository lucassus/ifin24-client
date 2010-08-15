# encoding: utf-8

module Ifin24
  class Console

    def initialize(client)
      @client = client
    end

    def main_menu
      catch :exit do
        loop do
          choose do |menu|
            menu.index = :letter
            menu.index_suffix = ") "
            menu.shell = true

            menu.choice("Dodaj wydatek") do
              add_entry
            end

            menu.choice("Lista kont") do
              list_accounts
            end

            menu.choice("Lista ostatnich transakcji") do
              list_entries
            end

            menu.choice("Koniec") do
              throw :exit
            end
          end
        end
      end
    end

    def get_entry
      entry = Models::Entry.new

      get_title(entry)
      get_date(entry)
      get_account(entry)
      get_category(entry)
      get_amount(entry)
      get_tags(entry)
      get_note(entry)

      return entry
    end

    def add_entry
      entry = get_entry

      catch :all_ok do
        loop do
          choose do |menu|
            menu.index = :letter
            menu.index_suffix = ") "
            menu.shell = true

            menu.choice("Nazwa: #{entry.title}") do
              get_title(entry)
            end

            menu.choice("Data: #{entry.date}") do
              get_date(entry)
            end

            menu.choice("Konto: #{entry.account.name}") do
              get_account(entry)
            end

            menu.choice("Kategoria: #{entry.category_full_name}") do
              get_category(entry)
            end

            menu.choice("Kwota: #{entry.amount}") do
              get_amount(entry)
            end

            menu.choice("Tagi: #{entry.tags}") do
              get_tags(entry)
            end

            menu.choice("Opis: #{entry.note}") do
              get_note(entry)
            end

            menu.choice("Powrót do głównego menu") do
              throw :all_ok
            end

            menu.choice("Wyślij") do
              puts "Wysyłanie danych..."
              @client.send_entry(entry)
              throw :all_ok
            end
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
            menu.shell = true

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

            menu.choice("Powrót do głównego menu") do
              throw :exit
            end
          end
        end
      end
    end

    private

    def print_list(items, *fields)
      # find max length for each field; start with the field names themselves
      fields = items.first.class.column_names unless fields.any?
      max_len = Hash[*fields.map { |f| [f, f.to_s.length] }.flatten]
      items.each do |item|
        fields.each do |field|
          len = item.send(field).to_s.length
          max_len[field] = len if len > max_len[field]
        end
      end

      border = '+-' + fields.map { |f| '-' * max_len[f] }.join('-+-') + '-+'
      title_row = '| ' + fields.map { |f| sprintf("%-#{max_len[f]}s", f.to_s) }.join(' | ') + ' |'

      puts border
      puts title_row
      puts border

      items.each do |item|
        row = '| ' + fields.map { |f| sprintf("%-#{max_len[f]}s", item.send(f)) }.join(' | ') + ' |'
        puts row
      end

      puts border
      puts "#{items.length} rows in set\n"
    end

    def get_title(entry)
      entry.title = ask('Nazwa: ')
    end

    def get_date(entry)
      curr_date = Date.today
      entry.date = ask('Data: ') do |q|
        q.default = curr_date
      end
    end

    def get_account(entry)
      choose do |menu|
        menu.prompt = 'Wybierz rachunek: '

        @client.accounts.each do |account|
          menu.choice(account.name) do
            entry.account = account
          end
        end
      end
    end

    def get_category(entry)
      choose do |menu|
        menu.prompt = 'Wybierz kategorię: '

        @client.categories.each do |category|
          menu.choice(category.name) do
            entry.category = category
          end
        end
      end

      choose do |menu|
        menu.prompt = 'Wybierz podkategorię: '

        entry.category.children.each do |child|
          menu.choice(child.name) do
            entry.sub_category = child
          end
        end
      end
    end

    def get_amount(entry)
      entry.amount = eval ask('Kwota: ')
    end

    def get_tags(entry)
      entry.tags = ask('Tagi: ')
    end

    def get_note(entry)
      entry.note = ask('Opis: ')
    end

  end
end
