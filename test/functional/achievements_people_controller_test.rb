require File.dirname(__FILE__) + '/../test_helper'

class AchievementsPeopleControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:achievements_people)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_achievements_person
    assert_difference('AchievementsPerson.count') do
      post :create, :achievements_person => { }
    end

    assert_redirected_to achievements_person_path(assigns(:achievements_person))
  end

  def test_should_show_achievements_person
    get :show, :id => achievements_people(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => achievements_people(:one).id
    assert_response :success
  end

  def test_should_update_achievements_person
    put :update, :id => achievements_people(:one).id, :achievements_person => { }
    assert_redirected_to achievements_person_path(assigns(:achievements_person))
  end

  def test_should_destroy_achievements_person
    assert_difference('AchievementsPerson.count', -1) do
      delete :destroy, :id => achievements_people(:one).id
    end

    assert_redirected_to achievements_people_path
  end
end
