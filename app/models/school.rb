# vim:tw=0:et:ts=2:

class School < ActiveRecord::Base
	has_many :people
	has_many :sessions

  def School.name_id_array
    return School.find(:all, :order => :name).collect {|s| [s.name, s.id]}
  end
end
