# encoding: utf-8

class Ifin24::Commands::ListLimits < Ifin24::Commands::Base
  BAR_SIZE = 50

  def execute
    limits = @client.fetch_limits
    limits.each do |limit|
      widest_name_size = limits.map { |l| l.name }.inject(0) { |max, name| name.size >= max ? name.size : max }
      name = limit.name.ljust(widest_name_size)
      limit_bar = make_limit_bar(limit.amount, limit.max)
      amount = "#{limit.amount}zł z #{limit.max}zł"

      puts "#{name} #{limit_bar} #{amount}"
    end
  end

  private

  def make_limit_bar(amount, max)
    amount = [amount, max].min
    taken = ((amount / max) * BAR_SIZE).to_i

    bar = "["
    taken.times do
      bar << "#"
    end

    (BAR_SIZE - taken).times do
      bar << "."
    end
    bar << "]"

    return bar
  end

end
