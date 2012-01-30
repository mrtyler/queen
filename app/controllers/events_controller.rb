# vim:tw=0:et:ts=2

class EventsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    if params[:start_date]
      @start_date = Date.parse(params[:start_date])
    else
      @start_date = Date.today - 7
    end
    if params[:end_date]
      @end_date = Date.parse(params[:end_date])
    else
      @end_date = Date.today + 28
    end
    
    @events = Event.find(:all, :conditions => ["date >= ? AND date <= ?", @start_date, @end_date ], :order => "date")
    @event_dates = @events.map { |e| e.date }
  end

  def list_orig
    @event_pages, @events = paginate :events, :per_page => 50
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(params[:event])
    @event.last_updated = Time.now
    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    @event.last_updated = Time.now
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully updated.'
      redirect_to :action => 'edit', :controller => 'sessions', :id => @event.session_id
    else
      render :action => 'edit'
    end
  end

  def destroy
    # save the session_id first so that we can redirect back to the Session
    # edit page
    @session_id = Event.find(params[:id]).session_id
    Event.find(params[:id]).destroy
    redirect_to :action => 'edit', :controller => 'sessions', :id => @session_id
  end

end
