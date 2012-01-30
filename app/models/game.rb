# vim:tw=0:et:ts=2:

class Game < ActiveRecord::Base
  has_many :people

end
