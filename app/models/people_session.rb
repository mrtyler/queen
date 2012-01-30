#vim tw=0:et:ts=2


class PeopleSession < ActiveRecord::Base
	has_many :people
	has_many :sessions
end
