# vim:tw=0:et:ts=2

class SessionsController < ApplicationController

  layout "application", :except => [ :flyer_template ]

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
    @session_pages, @sessions = paginate :sessions, :per_page => 100, :order => @sort
  end

  def show
    @session = Session.find(params[:id])
  end

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(params[:session])
    @session.last_updated = Time.now
    @errors = 0
    if @session.save
      flash[:notice] = 'Session was successfully created.'
    else
      @errors = 1
    end

    if @session.create_events_from_date_text(params[:date_text])
      flash[:notice].concat "<br/>\nEvents were successfully created."
    else
      @errors = 1
    end

    if @errors != 0
      raise "blarg create"
      render :action => 'new'
    else 
      redirect_to :action => 'list'
    end
  end

  def edit
    @session = Session.find(params[:id])
  end

  def update
    @session = Session.find(params[:id])
    @session.last_updated = Time.now
    @errors = 0
    if @session.update_attributes(params[:session])
      flash[:notice] = 'Session was successfully created.'
    else
      @errors = 1
    end

    if @session.create_events_from_date_text(params[:date_text])
      flash[:notice].concat "<br/>\nEvents were successfully created."
    else
      @errors = 1
    end

    if @errors != 0
      raise "blarg update"
      render :action => 'edit'
    else 
      redirect_to :action => 'list'
    end
  end

  def destroy
    # first destroy all of the Events that belong to us.
    # later, this should worry about Notes and other attachments
    Event.find(:all, :conditions => { :session_id => params[:id] }).each do |e| 
      e.destroy
    end
    Session.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def flyer_template
    @session = Session.find(params[:id])   
    if params[:person_id]
      @person = Person.find(params[:person_id])
    else
      # dummy object to prevent null pointers
      @person = Person.new
    end
  end

  def roll
    @session = Session.find(params[:id])
  
    if params[:checkbox]
      params[:checkbox].keys.each do |person_id|
        params[:checkbox][person_id].keys.each do |event_id|
          @existing_ep = EventsPerson.find(:first, :conditions => { :person_id => person_id, :event_id => event_id })
          if @existing_ep
            if params[:checkbox][person_id][event_id] == "yes"
              # EventsPerson exists and box is still checked. Do nothing.
            elsif params[:checkbox][person_id][event_id] == "no"
              # EventsPerson exists but box is not checked. Destroy EP.
              if @existing_ep.destroy
                flash[:notice] = "removed attendnace record for person #{person_id} from event #{event_id}.<br/>"
              end
            else
              print "EP exists but weird checkbox value.\n"
            end
          else
            if params[:checkbox][person_id][event_id] == "yes"
              # EventsPerson doesn't exist but box is checked. Create # EP.
              @ep = EventsPerson.new({:person_id => person_id, :event_id => event_id})
              if @ep.save
                flash[:notice] ="person #{person_id} added to event #{event_id}.<br/>"
              end
            elsif params[:checkbox][person_id][event_id] == "no"
              # EventsPerson doesn't exist and box isn't checked. Do nothing.
            else
              print "EP doesn't exist but weird checkbox value.\n"
            end
          end
        end
      end
    end
  end

  def contact
    @session = Session.find(params[:id])
  end

  def manage_people
    @session = Session.find(params[:id])

    if params[:checkbox]
      params[:checkbox].keys.each do |person_id|
        @existing_ps = PeopleSession.find(:first, :conditions => { :person_id => person_id, :session_id => @session.id })
        if @existing_ps
          if params[:checkbox][person_id] == "yes"
            # do nothing.
          elsif params[:checkbox][person_id] == "no"
            # remove this person from this session by destroying the
            # PeopleSession
            if @existing_ps.destroy
              flash[:notice] = "removed person #{person_id} from session #{@session.id}. NOTE: associated invoices not altered!<br/>"
            end
            # NOTE: invoices are not destroyed right now because that
            # doesn't seem right. for now, it flashes a warning.
          else
            print "exists and weird checkbox value\n"
          end
        else # no @existing_ps, so make a new one
          if params[:checkbox][person_id] == "yes"
            @ps = PeopleSession.new({:person_id => person_id, :session_id => @session.id})
            if @ps.save
              flash[:notice] ="person #{person_id} added to session #{@session.id}.<br/>"
            end
            # also create an invoice.
            if ! @session.get_all_dates.empty?
              @invoice_date = @session.get_all_dates.first
            else
              @invoice_date = Date.new(1970, 1, 1)
            end
            @i = Invoice.new( {
              :payer_id => person_id, 
              :amount => params[:cost][person_id], 
              :event_id => Event.find(:first, :order => "date ASC", :conditions => { :date => @invoice_date, :session_id => @session.id }).id,
              :payment_type_id => params[:payment_type_id][person_id],
              :payment_desc => params[:payment_desc][person_id] } )
           if @i.save
              flash[:notice] ="invoice created for person #{person_id} and session #{@session.id}.<br/>"
           end
          elsif params[:checkbox][person_id] == "no"
            # do nothing
          else
            print "doesn't exist and weird checkbox value\n"
          end
        end
      end
    end
  end
end
