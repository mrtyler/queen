class SchoolsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @school_pages, @schools = paginate :schools, :per_page => 10
  end

  def show
    @school = School.find(params[:id])
  end

  def new
    @school = School.new
  end

  def create
    @school = School.new(params[:school])
	@school.last_updated = Time.now
    if @school.save
      flash[:notice] = 'School was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @school = School.find(params[:id])
  end

  def update
    @school = School.find(params[:id])
	@school.last_updated = Time.now
    if @school.update_attributes(params[:school])
      flash[:notice] = 'School was successfully updated.'
      redirect_to :action => 'show', :id => @school
    else
      render :action => 'edit'
    end
  end

  def destroy
    School.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
