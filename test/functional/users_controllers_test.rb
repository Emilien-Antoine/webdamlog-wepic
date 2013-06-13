# setup environment before loading wltool.rb in wl_setup.rb
ENV["RAILS_ENV"] = "test"
ENV["USERNAME"] = "test_username"
ENV["PORT"] = "10000"
ENV["MANAGER_PORT"] = nil
require './lib/wl_setup'
WLSetup.reset_peer_databases Conf.db['database'], Conf.db['username'], Conf.db['adapter']
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  tests UsersController
  
  test "1index" do
    get(:index)
    assert_response :success
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:users)
    assert_not_nil assigns(:user_session)
  end

  test "2create" do
    post(:create,
      :user=>{
        :username => "test_username",
        :email => "test_user_email@emailprovider.dom",
        :password => "test_user_password",
        :password_confirmation => "test_user_password"
      })
    assert_not_nil assigns(:user)
    assert !(assigns(:user).new_record?), "@user should have been saved in the db"
    assert_response(302)
    assert_not_nil @response.body
    assert_redirected_to(:controller => "wepic")

    engine = EngineHelper::WLENGINE
    assert_not_nil engine
    assert engine.running_async
    assert_kind_of WLRunner, engine
    assert_equal([["sigmod_peer", "localhost:4100"], ["test_username", "localhost:5100"]], engine.wl_program.wlpeers.sort)
    assert_equal 6, engine.wl_program.wlcollections.size
    assert_equal ["comment_at_test_username",
      "contact_at_test_username",
      "describedrule_at_test_username",
      "picture_at_test_username",
      "picturelocation_at_test_username",
      "rating_at_test_username"], engine.wl_program.wlcollections.keys.sort
    assert_equal 2, engine.tables[:contact_at_test_username].values.size
    assert_equal 2, engine.wl_program.rule_mapping.size
    assert_equal [1,
      "rule contact@local($username, $peerlocation, $online, $email, $facebook):-contact@sigmod_peer($username, $peerlocation, $online, $email, $facebook);"],
      engine.wl_program.rule_mapping.keys
  end

  # test initialization of new webdamlog engine after user creation and add new
  # facts via async method
  test "3add" do
    post(:create,
      :user=>{
        :username => "test_username",
        :email => "test_user_email@emailprovider.dom",
        :password => "test_user_password",
        :password_confirmation => "test_user_password"
      })
    assert_not_nil assigns(:user)
    # #assert_response(200) # no redirection since it has been created in
    # previous test
    engine = EngineHelper::WLENGINE
    assert_not_nil engine
    assert engine.running_async
    assert_equal 8, engine.app_tables.size
    assert_equal 2, engine.tables[:contact_at_test_username].to_a.size
    assert_equal [:username, :peerlocation, :online, :email, :facebook], engine.tables[:contact_at_test_username].schema
    array = engine.tables[:contact_at_test_username].to_a.sort.map do |item|
      item.values
    end
    assert_equal [["Jules",
        "localhost:4100",
        "false",
        "jules.testard@mail.mcgill.ca",
        "Jules Testard"],
      ["Julia", "localhost:4100", "false", "stoyanovich@drexel.edu", "jstoy"]], array
    assert_equal 2, Contact.all.size
  end
  
end