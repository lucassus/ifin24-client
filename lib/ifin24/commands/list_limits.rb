# encoding: utf-8

class Ifin24::Commands::ListLimits < Ifin24::Commands::Base

  def execute
    limits = @client.fetch_limits
    print_list(limits, :name, :amount, :max)
  end

end
