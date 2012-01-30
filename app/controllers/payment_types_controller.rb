class PaymentTypesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @payment_type_pages, @payment_types = paginate :payment_types, :per_page => 10
  end

  def show
    @payment_type = PaymentType.find(params[:id])
  end

  def new
    @payment_type = PaymentType.new
  end

  def create
    @payment_type = PaymentType.new(params[:payment_type])
    if @payment_type.save
      flash[:notice] = 'PaymentType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @payment_type = PaymentType.find(params[:id])
  end

  def update
    @payment_type = PaymentType.find(params[:id])
    if @payment_type.update_attributes(params[:payment_type])
      flash[:notice] = 'PaymentType was successfully updated.'
      redirect_to :action => 'show', :id => @payment_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    PaymentType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
