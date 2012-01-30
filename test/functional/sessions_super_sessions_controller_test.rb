require File.dirname(__FILE__) + '/../test_helper'

class SessionsSuperSessionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:sessions_super_sessions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_sessions_super_session
    assert_difference('SessionsSuperSession.count') do
      post :create, :sessions_super_session => { }
    end

    assert_redirected_to sessions_super_session_path(assigns(:sessions_super_session))
  end

  def test_should_show_sessions_super_session
    get :show, :id => sessions_super_sessions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => sessions_super_sessions(:one).id
    assert_response :success
  end

  def test_should_update_sessions_super_session
    put :update, :id => sessions_super_sessions(:one).id, :sessions_super_session => { }
    assert_redirected_to sessions_super_session_path(assigns(:sessions_super_session))
  end

  def test_should_destroy_sessions_super_session
    assert_difference('SessionsSuperSession.count', -1) do
      delete :destroy, :id => sessions_super_sessions(:one).id
    end

    assert_redirected_to sessions_super_sessions_path
  end
end
