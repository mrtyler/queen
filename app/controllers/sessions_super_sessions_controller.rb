class SessionsSuperSessionsController < ApplicationController
  # GET /sessions_super_sessions
  # GET /sessions_super_sessions.xml
  def index
    @sessions_super_sessions = SessionsSuperSession.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sessions_super_sessions }
    end
  end

  # GET /sessions_super_sessions/1
  # GET /sessions_super_sessions/1.xml
  def show
    @sessions_super_session = SessionsSuperSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @sessions_super_session }
    end
  end

  # GET /sessions_super_sessions/new
  # GET /sessions_super_sessions/new.xml
  def new
    @sessions_super_session = SessionsSuperSession.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sessions_super_session }
    end
  end

  # GET /sessions_super_sessions/1/edit
  def edit
    @sessions_super_session = SessionsSuperSession.find(params[:id])
  end

  # POST /sessions_super_sessions
  # POST /sessions_super_sessions.xml
  def create
    @sessions_super_session = SessionsSuperSession.new(params[:sessions_super_session])

    respond_to do |format|
      if @sessions_super_session.save
        flash[:notice] = 'SessionsSuperSession was successfully created.'
        format.html { redirect_to(@sessions_super_session) }
        format.xml  { render :xml => @sessions_super_session, :status => :created, :location => @sessions_super_session }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sessions_super_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sessions_super_sessions/1
  # PUT /sessions_super_sessions/1.xml
  def update
    @sessions_super_session = SessionsSuperSession.find(params[:id])

    respond_to do |format|
      if @sessions_super_session.update_attributes(params[:sessions_super_session])
        flash[:notice] = 'SessionsSuperSession was successfully updated.'
        format.html { redirect_to(@sessions_super_session) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sessions_super_session.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sessions_super_sessions/1
  # DELETE /sessions_super_sessions/1.xml
  def destroy
    @sessions_super_session = SessionsSuperSession.find(params[:id])
    @sessions_super_session.destroy

    respond_to do |format|
      format.html { redirect_to(sessions_super_sessions_url) }
      format.xml  { head :ok }
    end
  end
end
