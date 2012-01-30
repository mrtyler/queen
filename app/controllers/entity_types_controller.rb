class EntityTypesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @entity_type_pages, @entity_types = paginate :entity_types, :per_page => 10
  end

  def show
    @entity_type = EntityType.find(params[:id])
  end

  def new
    @entity_type = EntityType.new
  end

  def create
    @entity_type = EntityType.new(params[:entity_type])
    if @entity_type.save
      flash[:notice] = 'EntityType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @entity_type = EntityType.find(params[:id])
  end

  def update
    @entity_type = EntityType.find(params[:id])
    if @entity_type.update_attributes(params[:entity_type])
      flash[:notice] = 'EntityType was successfully updated.'
      redirect_to :action => 'show', :id => @entity_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    EntityType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
