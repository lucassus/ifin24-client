module Ifin24
  # The current version of ifin24.
  # Do not change the value by hand; it will be updated automatically by the gem release script.
  VERSION = "0.0.1"

  autoload :Client, 'lib/ifin24/client'
  autoload :Console, 'lib/ifin24/console'
  autoload :Helpers, 'lib/ifin24/helpers'
  autoload :Models, 'lib/ifin24/models'
end
