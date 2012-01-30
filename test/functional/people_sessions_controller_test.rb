require File.dirname(__FILE__) + '/../test_helper'
require 'people_sessions_controller'

# Re-raise errors caught by the controller.
class PeopleSessionsController; def rescue_action(e) raise e end; end

class PeopleSessionsControllerTest < Test::Unit::TestCase
  fixtures :people_sessions

  def setup
    @controller = PeopleSessionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = people_sessions(:first).id
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

    assert_not_nil assigns(:people_sessions)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:people_session)
    assert assigns(:people_session).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:people_session)
  end

  def test_create
    num_people_sessions = PeopleSession.count

    post :create, :people_session => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_people_sessions + 1, PeopleSession.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:people_session)
    assert assigns(:people_session).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      PeopleSession.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      PeopleSession.find(@first_id)
    }
  end
end
