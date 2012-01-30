class BlackoutdatesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @blackoutdate_pages, @blackoutdates = paginate :blackoutdates, :per_page => 10
  end

  def show
    @blackoutdate = Blackoutdate.find(params[:id])
  end

  def new
    @blackoutdate = Blackoutdate.new
  end

  def create
    @blackoutdate = Blackoutdate.new(params[:blackoutdate])
    if @blackoutdate.save
      flash[:notice] = 'Blackoutdate was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @blackoutdate = Blackoutdate.find(params[:id])
  end

  def update
    @blackoutdate = Blackoutdate.find(params[:id])
    if @blackoutdate.update_attributes(params[:blackoutdate])
      flash[:notice] = 'Blackoutdate was successfully updated.'
      redirect_to :action => 'show', :id => @blackoutdate
    else
      render :action => 'edit'
    end
  end

  def destroy
    Blackoutdate.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
