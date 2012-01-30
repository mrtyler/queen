# vim:tw=0:et:ts=2

class SessionsSuperSession < ActiveRecord::Base
  has_many :sessions
end
