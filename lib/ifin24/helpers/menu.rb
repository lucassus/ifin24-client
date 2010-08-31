module Ifin24::Helpers
  module Menu

    def console_menu(exit_prompt)
      catch :exit do
        loop do
          choose do |menu|
            menu.index = :letter
            menu.index_suffix = ") "

            yield menu

            menu.choice(exit_prompt) { throw :exit }
          end
        end
      end
    end

  end
end
