# encoding: utf-8

class Ifin24::Commands::AddExpense < Ifin24::Commands::Base
  include Ifin24::Models

  def execute
    entry = get_entry

    catch :all_ok do
      loop do
        choose do |menu|
          menu.index = :letter
          menu.index_suffix = ") "

          menu.choice("Nazwa: #{entry.title}") { get_title_for(entry) }
          menu.choice("Data: #{entry.date}") { get_date_for(entry) }
          menu.choice("Konto: #{entry.account.name}") { get_account_for(entry) }
          menu.choice("Kategoria: #{entry.category_full_name}") { get_category_for(entry) }
          menu.choice("Kwota: #{entry.amount}") { get_amount_for(entry) }
          menu.choice("Tagi: #{entry.tags}") { get_tags_for(entry) }
          menu.choice("Opis: #{entry.note}") { get_note_for(entry) }

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

  private

  def get_entry
    entry = Entry.new

    get_title_for(entry)
    get_date_for(entry)
    get_account_for(entry)
    get_category_for(entry)
    get_amount_for(entry)
    get_tags_for(entry)
    get_note_for(entry)

    return entry
  end

  def get_title_for(entry)
    entry.title = ask('Nazwa: ')
  end

  def get_date_for(entry)
    curr_date = Date.today
    entry.date = ask('Data: ') do |q|
      q.default = curr_date
    end
  end

  def get_account_for(entry)
    choose do |menu|
      menu.prompt = 'Wybierz rachunek: '

      @client.accounts.each do |account|
        menu.choice(account.name) do
          entry.account = account
        end
      end
    end
  end

  def get_category_for(entry)
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

  def get_amount_for(entry)
    entry.amount = eval ask('Kwota: ')
  end

  def get_tags_for(entry)
    entry.tags = ask('Tagi: ')
  end

  def get_note_for(entry)
    entry.note = ask('Opis: ')
  end

end
