require File.dirname(__FILE__) + '/../test_helper'
require 'blackoutdates_controller'

# Re-raise errors caught by the controller.
class BlackoutdatesController; def rescue_action(e) raise e end; end

class BlackoutdatesControllerTest < Test::Unit::TestCase
  fixtures :blackoutdates

  def setup
    @controller = BlackoutdatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = blackoutdates(:first).id
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

    assert_not_nil assigns(:blackoutdates)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:blackoutdate)
    assert assigns(:blackoutdate).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:blackoutdate)
  end

  def test_create
    num_blackoutdates = Blackoutdate.count

    post :create, :blackoutdate => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_blackoutdates + 1, Blackoutdate.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:blackoutdate)
    assert assigns(:blackoutdate).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Blackoutdate.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Blackoutdate.find(@first_id)
    }
  end
end
