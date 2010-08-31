class Ifin24::Commands::Base
  include Ifin24::Helpers::Menu
  include Ifin24::Helpers::Printer

  def initialize(client)
    @client = client
  end

end
