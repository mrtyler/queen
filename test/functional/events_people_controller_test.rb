require File.dirname(__FILE__) + '/../test_helper'
require 'events_people_controller'

# Re-raise errors caught by the controller.
class EventsPeopleController; def rescue_action(e) raise e end; end

class EventsPeopleControllerTest < Test::Unit::TestCase
  fixtures :events_people

  def setup
    @controller = EventsPeopleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = events_people(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:events_people)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:events_person)
    assert assigns(:events_person).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:events_person)
  end

  def test_create
    num_events_people = EventsPerson.count

    post :create, :events_person => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_events_people + 1, EventsPerson.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:events_person)
    assert assigns(:events_person).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      EventsPerson.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      EventsPerson.find(@first_id)
    }
  end
end
