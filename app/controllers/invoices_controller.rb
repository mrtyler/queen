# vi:tw=0:et:ts=2

class InvoicesController < ApplicationController
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

    @filters = Array.new
    @filters.push(Filter.new({
      :name => "start_date",
      :display_name => "Start Date",
      :type => "text",
      :sql => "event_id in (select id from events where date >= :start_date)"}))
    @filters.push(Filter.new({
      :name =>"end_date",
      :display_name => "End Date",
      :type => "text",
      :sql => "event_id in (select id from events where date <= :end_date)"}))
    @filters.push(Filter.new({
      :name => "amount",
      :display_name => "Amount",
      :type => "text",
      :sql => "amount = :amount" }))
    @filters.push(Filter.new({
      :name => "person",
      :display_name => "Person",
      :type => "select",
      :op_vals => Person.find(:all, :order => "lname ASC, fname ASC").map {|p| ["#{p.lname}, #{p.fname}", p.id]},
      :sql => "payer_id = :person OR payee_id = :person",
      :blank_enabled => true }))

    # this wack-ass class name is so that i can write @filter_values[:name] as
    # well as @filter_values['name']
    @filter_values = HashWithIndifferentAccess.new
    # get the user-provided values for the filters back from the form
    @filters.each do |f|
      if params[f.label_name]
        @filter_values[f.label_name] = params[f.label_name]
      end
    end
  
    # build a (sanitized) sql statement with the user-provided filter values
    @filter_sql = Filter.condition_sql(@filters, @filter_values)

    @invoice_pages, @invoices = paginate :invoices, :per_page => 100, :order => @sort, :conditions => @filter_sql
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def new
    @invoice = Invoice.new
  end

  def create
    @invoice = Invoice.new(params[:invoice])
    @invoice.last_updated = Time.now
    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
  end

  def update
    @invoice = Invoice.find(params[:id])
    @invoice.last_updated = Time.now
    if @invoice.update_attributes(params[:invoice])
      flash[:notice] = 'Invoice was successfully updated.'
      redirect_to :action => 'show', :id => @invoice
    else
      render :action => 'edit'
    end
  end

  def destroy
    Invoice.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
