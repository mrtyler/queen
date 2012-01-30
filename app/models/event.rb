# vim:tw=0:et:ts=2:

class Event < ActiveRecord::Base
  belongs_to :session

  def description
    query = Session.find(self.session_id)
    query.nil? ? d = "" : d = "#{self.date}: #{query.school_name} ##{query.id} #{query.who}"
	return d
  end

  def Event.description_id_array(sanitized_condition_sql= "true = true")
    return Event.find(:all, :order => :date, :conditions => sanitized_condition_sql).collect {|e| [e.description, e.id]}
  end
end
