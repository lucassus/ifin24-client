# encoding: utf-8

class Ifin24::Commands::AddExpense < Ifin24::Commands::Base

  def execute
    entry = get_entry

    catch :all_ok do
      loop do
        choose do |menu|
          menu.index = :letter
          menu.index_suffix = ") "

          menu.choice("Nazwa: #{entry.title}") { get_title(entry) }
          menu.choice("Data: #{entry.date}") { get_date(entry) }
          menu.choice("Konto: #{entry.account.name}") { get_account(entry) }
          menu.choice("Kategoria: #{entry.category_full_name}") { get_category(entry) }
          menu.choice("Kwota: #{entry.amount}") { get_amount(entry) }
          menu.choice("Tagi: #{entry.tags}") { get_tags(entry) }
          menu.choice("Opis: #{entry.note}") { get_note(entry) }

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
    entry = Ifin24::Models::Entry.new

    get_title(entry)
    get_date(entry)
    get_account(entry)
    get_category(entry)
    get_amount(entry)
    get_tags(entry)
    get_note(entry)

    return entry
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
