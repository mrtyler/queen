class Note < ActiveRecord::Base
	belongs_to :people
	belongs_to :events
	belongs_to :schools
end
