require "test_helper"

class MainDeckControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get main_deck_show_url
    assert_response :success
  end
end