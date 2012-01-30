# vim:tw=0:et:ts=2

class Session < ActiveRecord::Base
  has_many :events

  def get_all_people
    ps = PeopleSession.find(:all, :conditions => { :session_id => self.id })
    people = ps.map { |p| Person.find(p.person_id) }
    people.sort! { |x,y| x.lname <=> y.lname }
    return people
  end

  # don't do it this way. do it in the view. this is just a quick proof of concept i guess.
  def display_all_people
    return_me = "<table><th>Name</th><th>Grade</th><th>Track</th></td>\n"
    self.get_all_people.each do |person|
      return_me.concat("<tr><td>#{person.lfname_link}</td><td>#{person.grade}</td><td>#{person.track}</td></tr>") 
    end
    return_me.concat("</table>\n")
    return return_me
  end

  def first_event_id
    e = Event.find(:first, :conditions => {:session_id => self.id }, :order => "date ASC")
    if e.nil?
      return 0
    else
      return e.id
    end
  end

  # returns an (empty if none) Array with all the Events that belong to this
  # Session, ordered ASC by Date
  def get_all_events
    return Event.find(:all, :conditions => { :session_id => self.id }, :order => "date ASC")
  end

  def get_all_dates
    return self.get_all_events.map { |d| d.date }
  end

  def get_all_dates_mm_dd
    all_dates = self.get_all_dates
    all_dates.map { |d| "#{d.month}/#{d.day}" }
  end
  
  # returns the number of Events that have this Session's session_id.
  # TODO: understand Tracks/Blackoutdates better
  def number_of_weeks_derived
    if self.number_of_weeks
      return self.number_of_weeks
    else
      return self.get_all_dates.length
    end
  end

  # returns the string "yyyy-mm-dd--yyyy-mm-dd" with the first and last Events
  # of the session.
  def from_to_dates
    all_dates = self.get_all_dates
    return "#{all_dates.first}--#{all_dates.last}"
  end

  def description
    return "#{self.school_name} ##{self.id} #{self.who}: #{self.from_to_dates}"
  end

  def school_name
    query = School.find(self.school_id)
    query.nil? ? sn = "" : sn = query.name
    return sn
  end

  def Session.description_id_array
    return Session.find(:all, :order => :id).collect {|s| [s.description, s.id]}
  end

  # returns the name of the day of the week that the FIRST Event is on.
  # TODO: make this smarter/better
  def day_of_week
    all_dates = self.get_all_dates
    if ! all_dates.empty?
      return Date::DAYNAMES[self.get_all_dates.first.wday] + "s"
    else
      return "No dates specified"
    end
  end

  # helper function for parsing user entry of Dates. i'm putting it in Session
  # for now, though it belongs further up the tree somewhere since Event and
  # Blackoutdate will want it periodically.
  def parse_date_text(date_text)
    return_me = Array.new

    # clean up the user input
    @date_text_ary = date_text.gsub(/\s/, ' ')

    @date_text_ary.split(/[,\s]/).each do |dt|
      next if dt.empty? # throw out "dates" that are just whitespace
      date_ary = ParseDate.parsedate(dt, guessYear=true)
      # if a year is not specified, dates that appear to be in the past are
      # actually for next year. (the tmp_date object is because there is no
      # Date.year= accessor and because I want Date to handle the date
      # comparisons.)
	  # BUG: this breaks for dates like 2/29 in 2007 because 20007-02-29
	  # is not a legal date. this is because i want 2/29 to be assumed
	  # to be next year (2008) which *is* a leap year and has a 2/29.
	  # argh.
      if date_ary[0].nil?
        date_ary[0] = Date.today.year
        tmp_date = Date.new(date_ary[0], date_ary[1], date_ary[2])
        if tmp_date < Date.today
          date_ary[0] = Date.today.year + 1
        end
      end
      date = Date.new(date_ary[0], date_ary[1], date_ary[2])
      return_me.push(date)
    end

    return return_me
  end

  # creates a bunch of Events based on comma- or whitespace-separated
  # dates.
  # Note: when using this from Session.create, make sure you call it
  # after @session.save so that @session.id gets a value.
  def create_events_from_date_text (date_text)
    # for now, Sessions with no Events are ok
    return true if ! date_text # catch nil
    return true if date_text.empty?

    dates=Array.new(self.parse_date_text(date_text))

    dates.each do |date|
      e = Event.new(:date => date, :session_id => self.id)
      e.save or raise "Problem creating Event"
    end

    return true
  end

end
