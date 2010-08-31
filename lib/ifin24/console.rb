# encoding: utf-8

class Ifin24::Console
  include Ifin24
  include Helpers::Menu

  def initialize(client)
    @client = client
  end

  def main_menu
    console_menu('Koniec') do |menu|
      menu.header = "Menu główne"

      menu.choice("Dodaj wydatek") { add_expense }
      menu.choice("Lista kont") { list_accounts }
      menu.choice("Lista ostatnich transakcji") { list_entries }
      menu.choice("Kontrola wydatków") { list_limits }
    end
  end

  def add_expense
    execute_command(Commands::AddExpense)
  end

  def list_accounts
    execute_command(Commands::ListAccounts)
  end

  def list_entries
    execute_command(Commands::ListEntries)
  end

  def list_limits
    execute_command(Commands::ListLimits)
  end

  private

  def execute_command(command)
    command.new(@client).execute
  end

end
