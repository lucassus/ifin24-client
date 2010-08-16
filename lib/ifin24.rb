module Ifin24
  autoload :Client, 'lib/ifin24/client'
  autoload :Console, 'lib/ifin24/console'

  # The current version of ifin24.
  # Do not change the value by hand; it will be updated automatically by the gem release script.
  VERSION = "0.0.1"
end

require 'lib/ifin24/models'
require 'lib/ifin24/helpers/printer'
