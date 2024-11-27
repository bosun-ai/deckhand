require "application_system_test_case"

class CodebaseAgentServicesTest < ApplicationSystemTestCase
  setup do
    @codebase_agent_service = codebase_agent_services(:one)
  end

  test "visiting the index" do
    visit codebase_agent_services_url
    assert_selector "h1", text: "Codebase agent services"
  end

  test "should create codebase agent service" do
    visit codebase_agent_services_url
    click_on "New codebase agent service"

    click_on "Create Codebase agent service"

    assert_text "Codebase agent service was successfully created"
    click_on "Back"
  end

  test "should update Codebase agent service" do
    visit codebase_agent_service_url(@codebase_agent_service)
    click_on "Edit this codebase agent service", match: :first

    click_on "Update Codebase agent service"

    assert_text "Codebase agent service was successfully updated"
    click_on "Back"
  end

  test "should destroy Codebase agent service" do
    visit codebase_agent_service_url(@codebase_agent_service)
    click_on "Destroy this codebase agent service", match: :first

    assert_text "Codebase agent service was successfully destroyed"
  end
end
