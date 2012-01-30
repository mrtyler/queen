require File.dirname(__FILE__) + '/../test_helper'
require 'schools_controller'

# Re-raise errors caught by the controller.
class SchoolsController; def rescue_action(e) raise e end; end

class SchoolsControllerTest < Test::Unit::TestCase
  fixtures :schools

  def setup
    @controller = SchoolsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = schools(:first).id
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

    assert_not_nil assigns(:schools)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:school)
    assert assigns(:school).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:school)
  end

  def test_create
    num_schools = School.count

    post :create, :school => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_schools + 1, School.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:school)
    assert assigns(:school).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      School.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      School.find(@first_id)
    }
  end
end
