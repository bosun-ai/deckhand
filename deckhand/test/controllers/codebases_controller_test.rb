require "test_helper"

class CodebasesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @codebase = codebases(:one)
  end

  test "should get index" do
    get codebases_url
    assert_response :success
  end

  test "should get new" do
    get new_codebase_url
    assert_response :success
  end

  test "should create codebase" do
    assert_difference("Codebase.count") do
      post codebases_url, params: { codebase: { name: @codebase.name, url: @codebase.url } }
    end

    assert_redirected_to codebase_url(Codebase.last)
  end

  test "should show codebase" do
    get codebase_url(@codebase)
    assert_response :success
  end

  test "should get edit" do
    get edit_codebase_url(@codebase)
    assert_response :success
  end

  test "should update codebase" do
    patch codebase_url(@codebase), params: { codebase: { name: @codebase.name, url: @codebase.url } }
    assert_redirected_to codebase_url(@codebase)
  end

  test "should destroy codebase" do
    assert_difference("Codebase.count", -1) do
      delete codebase_url(@codebase)
    end

    assert_redirected_to codebases_url
  end
end
