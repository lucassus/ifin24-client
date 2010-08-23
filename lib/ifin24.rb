module Ifin24
  # The current version of ifin24.
  # Do not change the value by hand; it will be updated automatically by the gem release script.
  VERSION = "0.0.1"

  autoload :Client, 'ifin24/client'
  autoload :Commands, 'ifin24/commands'
  autoload :Configuration, 'ifin24/configuration'
  autoload :Console, 'ifin24/console'
  autoload :Helpers, 'ifin24/helpers'
  autoload :Models, 'ifin24/models'
end
