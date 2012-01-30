# vi:tw=0:et:ts=2

class PeopleController < ApplicationController

  layout "application", :except => [ :addon, :paysheet ]

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if params[:sort]
      @sort = params[:sort]
    else
      @sort = "id DESC"
    end

    if params[:flyer_session_id]
      @flyer_session_id = params[:flyer_session_id]
    else
      @flyer_session_id = nil
    end

    # set up filters for this page 
    @filters = Array.new 
    @filters.push(Filter.new_school_id_filter) 
    @filters.push(Filter.new_name_filter) 
    @filters.push(Filter.new_email_filter) 
    @filters.push(Filter.new({
      :name => "track",
      :display_name => "Track",
      :type => "text",
      :sql => "track in (:track)" }))
    @filters.push(Filter.new({
      :name => "session",
      :display_name => "Session",
      :type => "select",
      :op_vals => Session.description_id_array,
      :sql => "id in (SELECT person_id FROM people_sessions where session_id = :session)",
      :blank_enabled => true }))
    @filters.push(Filter.new({
      :name => "instructor",
      :display_name => "Instructor",
      :type => "select",
      :op_vals => [ [ "yes", 1 ], [ "no", 0 ] ],
      :sql => "instructor = :instructor",
      :blank_enabled => true }))
    @filters.push(Filter.new({
      :name => "flyer_session",
      :display_name => "Session for flyers",
      :type => "select",
      :op_vals => Session.description_id_array,
      :sql => "true = true",
      :blank_enabled => true }))

    # this wack-ass class name is so that i can write @filter_values[:name] as
    # well as @filter_values['name']
    @filter_values = HashWithIndifferentAccess.new
    # get the user-provided values for the filters back from the form
    @filters.each do |f|
      if params[f.label_name]
        @filter_values[f.label_name] = params[f.label_name]
      end
    end
  
    # build a (sanitized) sql statement with the user-provided filter values
    @filter_sql = Filter.condition_sql(@filters, @filter_values)

    # use the unsafe :conditions because otherwise it gets confused by
    # substring searches, so we do the escaping in Filter.condition_sql
    @person_pages, @people = paginate :people, :per_page => 100, :order => @sort, :conditions => @filter_sql

  # pretty hacky. make a list of emails of all *displayed* people.
  # (sucks with pagination, as does everything.)
  @emails = @people.map { |p| p.email }.sort.uniq.compact
  @emails.delete("")
  @emails.delete_if { |x| x.match(/!/) }
  @emails.delete_if { |x| x.match(/DOES NOT WORK/) }
  end

  def show
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    @person.last_updated = Time.now
    if @person.save
      flash[:notice] = 'Person was successfully created.'
      redirect_to :action => 'new'
    else
      render :action => 'new'
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(params[:id])
    @person.last_updated = Time.now
    if @person.update_attributes(params[:person])
      flash[:notice] = 'Person was successfully updated.'
      redirect_to :action => 'show', :id => @person
    else
      render :action => 'edit'
    end
  end

  def destroy
    Person.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def addon
    @person = Person.find(params[:id])
    #ps = PeopleSession.find(:first, :order => "session_id DESC", :conditions => { :person_id => @person.id })
    #@session = Session.find(ps.session_id)
    @session = Session.find(params[:session_id])
  end

  def stats
    if params[:sort]
      @sort = params[:sort]
    else
      @sort = "rating DESC"
    end

    # set up filters for this page 
    @filters = Array.new 
    @filters.push(Filter.new({
      :name => "school_id",
      :display_name => "School",
      :type => "select",
      :op_vals => School.name_id_array,
      :sql => "school_id = :school_id",
      :blank_enabled => true }))

    # this wack-ass class name is so that i can write @filter_values[:name] as
    # well as @filter_values['name']
    @filter_values = HashWithIndifferentAccess.new
    # get the user-provided values for the filters back from the form
    @filters.each do |f|
      if params[f.label_name]
        @filter_values[f.label_name] = params[f.label_name]
      end
    end
  
    # build a (sanitized) sql statement with the user-provided filter values
    @filter_sql = Filter.condition_sql(@filters, @filter_values)

    # use the unsafe :conditions because otherwise it gets confused by
    # substring searches, so we do the escaping in Filter.condition_sql
    @people = Person.find(:all, :order => @sort, :conditions => @filter_sql)

    @stats = Hash.new
    @people.each do |person|
      games = Game.find(:all, :conditions => [ "(white_id = ? OR black_id = ?)", person.id, person.id ])
      @stats[person.id] = Hash.new
      @stats[person.id]['wins'] = 0
      @stats[person.id]['losses'] = 0
      @stats[person.id]['draws'] = 0
      @stats[person.id]['won_against'] = ''
      @stats[person.id]['lost_against'] = ''
      @stats[person.id]['drew_against'] = ''
      @stats[person.id]['has_games'] = false
      if games.empty?
        # get rid of People who don't have any associated Games
      else
        # initialize some values if this Person has some associated Games
        @stats[person.id]['has_games'] = true
        # now count results from the set of Games
        games.each do |game|
          if game.white_id == person.id
            color = 'white'
            opponent_id = game.black_id
          elsif game.black_id == person.id
            color = 'black'
            opponent_id = game.white_id
          else
            color = 'BROKEN'
            opponent_id = 'BROKEN'
          end

          opponent = Person.find(opponent_id)
          opponent_name = "#{opponent.fname} #{opponent.lname}" if opponent

          if game.winner_id == person.id
            winner_id = person.id
            loser_id = opponent_id
            @stats[person.id]['wins'] = @stats[person.id]['wins'].succ
            @stats[person.id]['won_against'] = @stats[person.id]['won_against'] + ", " unless @stats[person.id]['won_against'].empty?
            @stats[person.id]['won_against'] = @stats[person.id]['won_against'] + opponent_name
         elsif game.winner_id == opponent_id
            winner = opponent_id
            loser = person.id
            @stats[person.id]['losses'] = @stats[person.id]['losses'].succ
            @stats[person.id]['lost_against'] = @stats[person.id]['lost_against'] + ", " unless @stats[person.id]['lost_against'].empty?
            @stats[person.id]['lost_against'] = @stats[person.id]['lost_against'] + opponent_name
         else
            winner = 'draw'
            loser = 'draw'
            @stats[person.id]['draws'] = @stats[person.id]['draws'].succ
            @stats[person.id]['drew_against'] = @stats[person.id]['drew_against'] + ", " unless @stats[person.id]['drew_against'].empty?
            @stats[person.id]['drew_against'] = @stats[person.id]['drew_against'] + opponent_name
          end
        end
      end
    end

    @people.sort! { |x,y| y.rating <=> x.rating }
    # TODO: fix ranking by sorting on losses, draws
    #@people.sort! { |x,y| @stats[y.id]['losses'] <=> @stats[x.id]['losses'] }
    #@people.sort! { |x,y| @stats[y.id]['wins'] <=> @stats[x.id]['wins'] }

    ###@person_pages, @people = paginate :people, :per_page => 25, :order => @sort, :conditions => @filter_sql
 
  end

  def instr_roll
    @instructor = Person.find(params[:id])
    # this can probably be generalized to do roll for any person... or not because we're going to do invoices here.
    exit "Person #{@instructor.id} is not an instructor." unless @instructor.instructor
  
    if params[:start_date]
      @start_date = Date.parse(params[:start_date])
    else
      @start_date = Invoice.pay_period_start_date
    end
    if params[:end_date]
      @end_date = Date.parse(params[:end_date])
    else
      @end_date = Invoice.pay_period_end_date
    end

    @events = Event.find(:all, :order => "date ASC", :conditions => [ "date >= ? AND date <= ?", @start_date, @end_date ]) 

    if params[:checkbox]
      params[:checkbox].keys.each do |event_id|
        existing_ep = EventsPerson.find(:first, :conditions => { :person_id => @instructor.id, :event_id => event_id })
        if params[:checkbox][event_id] == "yes"
          if existing_ep
            # EventsPerson exists and box is checked. Do nothing.
          else
            # EventsPerson doesn't exist but box is checked. Create EP and Invoice.
            flash[:notice] = ""
            ep = EventsPerson.new( { :person_id => @instructor.id, :event_id => event_id } )
            if ep.save
              flash[:notice] = flash[:notice] + "Created attendance record for instructor #{@instructor.id} and event #{event_id}.<br/>"
            else
              exit "Couldn't create attendance record for instructor #{@instructor.id} and event #{event_id}."
            end
            invoice = Invoice.new( { :payee_id => @instructor.id, :event_id => event_id, :amount => params[:rate][event_id] } )
            if invoice.save
              flash[:notice] = flash[:notice] + "Created invoice for instructor #{@instructor.id} and event #{event_id}.<br/>"
            else
              exit "Couldn't create invoice for instructor #{@instructor.id} and event #{event_id}."
            end
          end
        elsif params[:checkbox][event_id] == "no"
          if existing_ep
            # EventsPerson exists but box is unchecked. Destroy EP and Invoice.
            flash[:notice] = ""
            invoice = Invoice.find(:first, :conditions => { :payee_id => @instructor.id, :event_id => event_id})
            if invoice.destroy
              flash[:notice] = flash[:notice] + "Deleted invoice for instructor #{@instructor.id} and event #{event_id}.<br/>"
            else
              exit "Couldn't destroy invoice for instructor #{@instructor.id} and event #{event_id}."
            end
            if existing_ep.destroy
              flash[:notice] = flash[:notice] + "Deleted attendance record for instructor #{@instructor.id} and event #{event_id}.<br/>"
            else
              exit "Couldn't delete attendance record for instructor #{@instructor.id} and event #{event_id}."
            end
          else
            # EventsPerson doesn't exist and box is unchecked. Do nothing.
          end
        else
          exit "Weird checkbox value #{params[:checkbox][event_id]}."
        end
      end
    end

  end

  def paysheet
    @person = Person.find(params[:id])
  
    if params[:start_date]
      @start_date = Date.parse(params[:start_date])
    else
      @start_date = Invoice.pay_period_start_date
    end
    if params[:end_date]
      @end_date = Date.parse(params[:end_date])
    else
      @end_date = Invoice.pay_period_end_date
    end
  
    @invoices = Invoice.find(:all, :conditions => [ "payee_id = ? AND event_id IN (SELECT id FROM events WHERE date >= ? AND date <= ?)", @person.id, @start_date, @end_date ])
    @invoices.sort! { |x,y| Event.find(x.event_id).date <=> Event.find(y.event_id).date }
  end
  
  def manage_sessions
    @person = Person.find(params[:id])
    # TODO: can limit here by school, school+tourn, active/inactive, or whatever
    @sessions = Session.find(:all, :order => "id DESC")
    #@sessions = Session.find(:all, :order => "id DESC", :conditions => { :school_id => @person.school_id })

    # if the checkboxes are set up, we need to process form data coming back
    # from the user.
    if params[:enrolled_checkbox]
      params[:enrolled_checkbox].keys.each do |session_id|
        if @person.is_enrolled(session_id)
          if params[:enrolled_checkbox][session_id] == "yes"
            # box is checked and person is enrolled. do nothing.
          else
            # box is not checked and person is enrolled. unenroll person.
            @person.unenroll(session_id)
          end

          # if person is enrolled, then there should be an invoice and the user
          # might have made changes to that invoice. notice that and deal with
          # it here.
          session = Session.find(session_id)
          invoice = Invoice.find(:first, :conditions => { :payer_id => @person.id, :event_id => session.first_event_id })
          raise Exception.new("null invoice for person #{@person.id} with session first_event_id #{session.first_event_id}.") if invoice.nil?
          changed = false
          if params[:payment_type_id][session_id] != invoice.payment_type_id
            changed = true
            invoice.payment_type_id = params[:payment_type_id][session_id]
          end
          if params[:cost][session_id] != invoice.amount
            changed = true
            invoice.amount = params[:cost][session_id]
          end
          if params[:payment_desc][session_id] != invoice.payment_desc
            changed = true
            invoice.payment_desc = params[:payment_desc][session_id]
          end

          if changed
            if invoice.save!
              flash[:notice] = "invoice #{invoice.id} updated.<br/>"
            else
              raise Exception.new("invoice #{invoice.id} could not be updated.<br/>")
            end
          end
        else
          if params[:enrolled_checkbox][session_id] == "yes"
            # box is checked and person is not enrolled. enroll person.
            @person.enroll(session_id, 
                           params[:payment_type_id][session_id],
                           params[:cost][session_id],
                           params[:payment_desc][session_id])
          else
            # box is not checke and person is not enrolled. do nothing.
          end
        end
      end
    end
  end

end
