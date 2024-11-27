require "test_helper"

class CodebaseAgentServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @codebase_agent_service = codebase_agent_services(:one)
  end

  test "should get index" do
    get codebase_agent_services_url
    assert_response :success
  end

  test "should get new" do
    get new_codebase_agent_service_url
    assert_response :success
  end

  test "should create codebase_agent_service" do
    assert_difference("CodebaseAgentService.count") do
      post codebase_agent_services_url, params: { codebase_agent_service: {  } }
    end

    assert_redirected_to codebase_agent_service_url(CodebaseAgentService.last)
  end

  test "should show codebase_agent_service" do
    get codebase_agent_service_url(@codebase_agent_service)
    assert_response :success
  end

  test "should get edit" do
    get edit_codebase_agent_service_url(@codebase_agent_service)
    assert_response :success
  end

  test "should update codebase_agent_service" do
    patch codebase_agent_service_url(@codebase_agent_service), params: { codebase_agent_service: {  } }
    assert_redirected_to codebase_agent_service_url(@codebase_agent_service)
  end

  test "should destroy codebase_agent_service" do
    assert_difference("CodebaseAgentService.count", -1) do
      delete codebase_agent_service_url(@codebase_agent_service)
    end

    assert_redirected_to codebase_agent_services_url
  end
end
