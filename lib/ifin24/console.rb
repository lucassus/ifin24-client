# encoding: utf-8

class Ifin24::Console

  def initialize(client)
    @client = client
  end

  def main_menu
    catch :exit do
      loop do
        choose do |menu|
          menu.header = "Menu główne"
          menu.index = :letter
          menu.index_suffix = ") "

          menu.choice("Dodaj wydatek") { add_expense }
          menu.choice("Lista kont") { list_accounts }
          menu.choice("Lista ostatnich transakcji") { list_entries }

          menu.choice("Koniec") { throw :exit }
        end
      end
    end
  end

  def add_expense
    execute_command(Ifin24::Commands::AddExpense)
  end

  def list_accounts
    execute_command(Ifin24::Commands::ListAccounts)
  end

  def list_entries
    execute_command(Ifin24::Commands::ListEntries)
  end

  private

  def execute_command(command)
    command.new(@client).execute
  end

end
