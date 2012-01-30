class PeopleSessionsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @people_session_pages, @people_sessions = paginate :people_sessions, :per_page => 10
  end

  def show
    @people_session = PeopleSession.find(params[:id])
  end

  def new
    @people_session = PeopleSession.new
  end

  def create
    @people_session = PeopleSession.new(params[:people_session])
    @people_session.last_update = Time.now
    if @people_session.save
      flash[:notice] = 'PeopleSession was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @people_session = PeopleSession.find(params[:id])
  end

  def update
    @people_session = PeopleSession.find(params[:id])
    if @people_session.update_attributes(params[:people_session])
      flash[:notice] = 'PeopleSession was successfully updated.'
      redirect_to :action => 'show', :id => @people_session
    else
      render :action => 'edit'
    end
  end

  def destroy
    PeopleSession.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
