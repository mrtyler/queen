class ResultTypesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @result_type_pages, @result_types = paginate :result_types, :per_page => 10
  end

  def show
    @result_type = ResultType.find(params[:id])
  end

  def new
    @result_type = ResultType.new
  end

  def create
    @result_type = ResultType.new(params[:result_type])
    if @result_type.save
      flash[:notice] = 'ResultType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @result_type = ResultType.find(params[:id])
  end

  def update
    @result_type = ResultType.find(params[:id])
    if @result_type.update_attributes(params[:result_type])
      flash[:notice] = 'ResultType was successfully updated.'
      redirect_to :action => 'show', :id => @result_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    ResultType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
