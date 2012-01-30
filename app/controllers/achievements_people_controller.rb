class AchievementsPeopleController < ApplicationController
  # GET /achievements_people
  # GET /achievements_people.xml
  def index
    @achievements_people = AchievementsPerson.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @achievements_people }
    end
  end

  # GET /achievements_people/1
  # GET /achievements_people/1.xml
  def show
    @achievements_person = AchievementsPerson.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @achievements_person }
    end
  end

  # GET /achievements_people/new
  # GET /achievements_people/new.xml
  def new
    @achievements_person = AchievementsPerson.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @achievements_person }
    end
  end

  # GET /achievements_people/1/edit
  def edit
    @achievements_person = AchievementsPerson.find(params[:id])
  end

  # POST /achievements_people
  # POST /achievements_people.xml
  def create
    @achievements_person = AchievementsPerson.new(params[:achievements_person])

    respond_to do |format|
      if @achievements_person.save
        flash[:notice] = 'AchievementsPerson was successfully created.'
        format.html { redirect_to(@achievements_person) }
        format.xml  { render :xml => @achievements_person, :status => :created, :location => @achievements_person }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @achievements_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /achievements_people/1
  # PUT /achievements_people/1.xml
  def update
    @achievements_person = AchievementsPerson.find(params[:id])

    respond_to do |format|
      if @achievements_person.update_attributes(params[:achievements_person])
        flash[:notice] = 'AchievementsPerson was successfully updated.'
        format.html { redirect_to(@achievements_person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @achievements_person.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /achievements_people/1
  # DELETE /achievements_people/1.xml
  def destroy
    @achievements_person = AchievementsPerson.find(params[:id])
    @achievements_person.destroy

    respond_to do |format|
      format.html { redirect_to(achievements_people_url) }
      format.xml  { head :ok }
    end
  end
end
