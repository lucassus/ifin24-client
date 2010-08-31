# encoding: utf-8

class Ifin24::Commands::ListLimits < Ifin24::Commands::Base
  LIMIT_BAR_SIZE = 64

  def execute
    limits = @client.fetch_limits
    widest_name_size = limits.inject(0) { |max, limit| limit.name.size >= max ? limit.name.size : max }

    limits.each do |limit|
      name = limit.name.ljust(widest_name_size)
      limit_bar = make_limit_bar(limit.amount, limit.max)
      amount_summary = "#{limit.amount}zł z #{limit.max}zł"

      puts "#{name} #{limit_bar} #{amount_summary}"
    end

    total_amount = limits.inject(0) { |sum, limit| sum += limit.amount }
    total_max = limits.inject(0) { |sum, limit| sum += limit.max }

    total_name = 'Podsumowanie:'.ljust(widest_name_size)
    total_limit_bar = make_limit_bar(total_amount, total_max)
    total_amount_summary = "#{total_amount}zł z #{total_max}zł"

    puts "\n#{total_name} #{total_limit_bar} #{total_amount_summary}"
  end

  private

  def make_limit_bar(amount, max)
    limit_exceeded = amount >= max
    amount = [amount, max].min
    taken = ((amount / max) * LIMIT_BAR_SIZE).to_i

    bar = "["
    taken.times do
      bar << "#".color(limit_exceeded ? :red : :green)
    end

    (LIMIT_BAR_SIZE - taken).times do
      bar << "."
    end
    bar << "]"

    return bar
  end

end
