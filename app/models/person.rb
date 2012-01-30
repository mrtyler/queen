# vi:tw=0:et:ts=2

class Person < ActiveRecord::Base
  belongs_to :school
  has_many :notes

  def enrolled_checkbox(session_id)
    return_me = ""
    is_enrolled = self.is_enrolled(session_id)
    return_me.concat("cur: #{is_enrolled ? "x" : "_"} change to: ")
    return_me.concat("<input name =\"enrolled_checkbox[#{session_id}]\" type=\"checkbox\" value=\"yes\" ")
    return_me.concat("checked=\"checked\"") if is_enrolled
    return_me.concat(">")
    return_me.concat("<input name=\"enrolled_checkbox[#{session_id}]\" type=\"hidden\" value=\"no\">")
    return return_me
  end

  def is_enrolled(session_id)
    return ! PeopleSession.find(:all, :conditions => { :person_id => self.id, :session_id => session_id }).empty?
  end

  def enroll(session_id, payment_type_id, cost, payment_desc)
    ps = PeopleSession.new({ :person_id => self.id, :session_id => session_id })
    if ps.save
      #flash[:notice] = "enrolled #{self.id} in #{session_id}"
    else
      raise Exception.new("couldn't enroll #{self.id} in #{session_id}")
    end

    s = Session.find(session_id)
    i = Invoice.new({ :payer_id => self.id,
                      :payment_type_id => payment_type_id,
                      :amount => cost,
                      :payment_desc => payment_desc,
                      :event_id => s.first_event_id })
    if i.save
      #flash[:notice] = "invoice created for enrollment of #{self.id} into #{session_id}.<br/>"
    else
      raise Exception.new("couldn't create invoice for enrollment of #{self.id} into #{session_id} with payment_type_id #{payment_type_id} amount #{cost} payment_desc #{payment_desc}")
    end
                      
  end

  def unenroll(session_id)
    ps = PeopleSession.find(:first, :conditions => { :person_id => self.id, :session_id => session_id })
    if ps.destroy
      #flash[:notice] = "removed person #{self.id} from session #{session_id}. NOTE: associated invoices not altered.<br/>"
    else
      raise Exception.new("Couldn't unenroll #{self.id} from #{session_id}.")
    end
  end

  def get_all_enrolled_sessions
    ps = PeopleSession.find(:all, :conditions => { :person_id => self.id })
    sessions = ps.map { |s| Session.find(s.session_id) } 
    sessions.sort! { |x,y| x.get_all_dates.first <=> y.get_all_dates.first }
    return sessions
  end

  def display_all_enrolled_sessions
    return_me = ""
    es = self.get_all_enrolled_sessions
    es.each do |s|
      return_me.concat(s.description + "<br/>\n")
    end

    return return_me
  end

  def lfname
    return "#{self.lname}, #{self.fname}"
  end

  def lfname_link
    return "<a href=\"/people/edit/#{self.id}\">#{self.lfname}</a>"
  end

  def flname
    return "#{self.fname} #{self.lname}"
  end

  def Person.name_id_array
    return Person.find(:all, :order => "lname, fname").collect {|p| ["#{p.lname}, #{p.fname}", p.id] }
  end

end
