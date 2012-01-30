class EventsPeopleController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @events_person_pages, @events_people = paginate :events_people, :per_page => 10
  end

  def show
    @events_person = EventsPerson.find(params[:id])
  end

  def new
    @events_person = EventsPerson.new
  end

  def create
    @events_person = EventsPerson.new(params[:events_person])
    if @events_person.save
      flash[:notice] = 'EventsPerson was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @events_person = EventsPerson.find(params[:id])
  end

  def update
    @events_person = EventsPerson.find(params[:id])
    if @events_person.update_attributes(params[:events_person])
      flash[:notice] = 'EventsPerson was successfully updated.'
      redirect_to :action => 'show', :id => @events_person
    else
      render :action => 'edit'
    end
  end

  def destroy
    EventsPerson.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
