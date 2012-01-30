# vim:ts=2:et:tw=0

class GamesController < ApplicationController
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

    # set up filters for this page 
    @filters = Array.new 
    @filters.push(Filter.new({
      :name => "result_type_id",
      :display_name => "Result",
      :type => "select",
      :op_vals => ResultType.name_id_array,
      :sql => "result_type_id = :result_type_id",
      :blank_enabled => true }))
    @filters.push(Filter.new({
      :name => "session_id",
      :display_name => "Session",
      :type => "select",
      :op_vals => Session.description_id_array,
      :sql => "event_id IN (SELECT id FROM events WHERE session_id = :session_id)",
      :blank_enabled => true }))
    @filters.push(Filter.new({
      :name => "school_id",
      :display_name => "School",
      :type => "select",
      :op_vals => School.name_id_array,
      :sql => "event_id IN (SELECT id FROM events WHERE session_id IN (SELECT id FROM sessions WHERE school_id = :school_id))",
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

    # use the unsafe :conditions because otherwise it gets confused by
    # substring searches, so we do the escaping in Filter.condition_sql
    @game_pages, @games = paginate :games, :per_page => 200, :order => @sort, :conditions => @filter_sql
  end

  def show
    @game = Game.find(params[:id])
  end

  def new
    @filters = Array.new 
    @filters.push(Filter.new({
      :name => "school_id",
      :display_name => "Filter player drop-downs by this school",
      :type => "select",
      :op_vals => School.name_id_array,
      :sql => "school_id = :school_id",
      :blank_enabled => true }))
	if params['filter_school_id'] && ! params['filter_school_id'].empty?
	  event_array = Event.find(:all, :conditions => "session_id IN (SELECT id FROM sessions WHERE school_id = #{ActiveRecord::Base.sanitize(params['filter_school_id'])})", :order => "date ASC").map { |e| [e.description, e.id] }
  else
    event_array = Event.description_id_array
  end
    @filters.push(Filter.new({
      :name => "event_id",
      :display_name => "Use this event_id",
      :type => "select",
      :op_vals => event_array,
      :sql => "true = true", # we use this filter value in a different way
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

    @game = Game.new
  end

  def create
    @game = Game.new(params[:game])
    if @game.event_id.nil?
      @game.event_id = params['filter_event_id']
    end
    @game.last_updated = Time.now
    if @game.save
      flash[:notice] = 'Game was successfully created.'
      redirect_to :action => 'new', :filter_event_id => params[:filter_event_id], :filter_school_id => params[:filter_school_id]
    else
      render :action => 'new'
    end
  end

  def edit
    @filters = Array.new 
    @filters.push(Filter.new({
      :name => "school_id",
      :display_name => "Filter player drop-downs by this school",
      :type => "select",
      :op_vals => School.name_id_array,
      :sql => "school_id = :school_id",
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

    @game = Game.find(params[:id])
  end

  def update
    @game = Game.find(params[:id])
    @game.last_updated = Time.now
    if @game.update_attributes(params[:game])
      flash[:notice] = 'Game was successfully updated.'
      redirect_to :action => 'show', :id => @game
    else
      render :action => 'edit'
    end
  end

  def destroy
    Game.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def regenerate_ratings
    if params[:default_rating]
      @default_rating = params[:default_rating]
    else
      @default_rating = 0
    end

    if @default_rating != 0
      count = 0
      
      # only do this when you want to obliterate old ratings
      Person.find(:all).each do |p|
        p.update_attribute('rating', @default_rating) or raise "couldn't set default rating for person #{p.id}"
      end

      games = Game.find(:all, :order => "id ASC") # order by event somehows
      games.each do |g|
        white = Person.find(g.white_id)
        black = Person.find(g.black_id)
        if g.winner_id
          winner = Person.find(g.winner_id)
        end

        r = white.rating
        if r && r != 0
          g.white_old_rating = r
        else
          g.white_old_rating = @default_rating
        end

        r = black.rating
        if r && r != 0
          g.black_old_rating = r
        else
          g.black_old_rating = @default_rating
        end

        if white == winner
          white_result = 1
          black_result = 0
          #g.white_new_rating = g.white_old_rating + 10
          #g.black_new_rating = g.black_old_rating - 10
        elsif black == winner
          white_result = 0
          black_result = 1
          #g.white_new_rating = g.white_old_rating - 10
          #g.black_new_rating = g.black_old_rating + 10
        else # just assume it's a draw. this could catch a data integrity error.
          white_result = 0.5
          black_result = 0.5
          #g.white_new_rating = g.white_old_rating + 1
          #g.black_new_rating = g.black_old_rating + 1
        end

        # here is the Elo formula:
        # new_rating = old_rating + K * (result - ( 1 / ( 1 + 10 ** ( opponent_old_rating - old_rating ) / 400 ) ) )
        k = 32 # commonly used coefficient for young/provisional players.
        g.white_new_rating = g.white_old_rating + k *
          (white_result -
            (1.0 /
              (1.0 + 10.0 **
                ((g.black_old_rating - g.white_old_rating) / 400)
        )))
        g.black_new_rating = g.black_old_rating + k *
          (black_result -
            (1.0 /
              (1.0 + 10.0 **
                ((g.white_old_rating - g.black_old_rating) / 400)
        )))

        white.rating = g.white_new_rating
        black.rating = g.black_new_rating
        
        print "game id: #{g.id}. white old: #{g.white_old_rating}. white new: #{g.white_new_rating}. white person: #{white.rating}. black old: #{g.black_old_rating}. black new: #{g.black_new_rating}. black person: #{black.rating}\n"
        if white.save && black.save && g.save
          # do nothing
        else
          print "PROBLEM UPDATING white #{white} and black #{black} from game #{g}\n"
        end

        count = count.succ
      end
      flash[:notice] = "Regenerated #{count} ratings with default value #{@default_rating}."
    end
  end
end
