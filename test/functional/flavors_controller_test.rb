require 'test_helper'

class FlavorsControllerTest < ActionController::TestCase
  setup do
    @flavor = flavors(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:flavors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create flavor" do
    assert_difference('Flavor.count') do
      post :create, :flavor => @flavor.attributes
    end

    assert_redirected_to flavor_path(assigns(:flavor))
  end

  test "should show flavor" do
    get :show, :id => @flavor.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @flavor.to_param
    assert_response :success
  end

  test "should update flavor" do
    put :update, :id => @flavor.to_param, :flavor => @flavor.attributes
    assert_redirected_to flavor_path(assigns(:flavor))
  end

  test "should destroy flavor" do
    assert_difference('Flavor.count', -1) do
      delete :destroy, :id => @flavor.to_param
    end

    assert_redirected_to flavors_path
  end
end
