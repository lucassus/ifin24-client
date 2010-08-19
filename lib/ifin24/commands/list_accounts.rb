# encoding: utf-8

class Ifin24::Commands::ListAccounts < Ifin24::Commands::Base

  def execute
    print_list(@client.accounts, :name)
  end

end
