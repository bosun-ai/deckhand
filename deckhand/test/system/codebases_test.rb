require "application_system_test_case"

class CodebasesTest < ApplicationSystemTestCase
  setup do
    @codebase = codebases(:one)
  end

  test "visiting the index" do
    visit codebases_url
    assert_selector "h1", text: "Codebases"
  end

  test "should create codebase" do
    visit codebases_url
    click_on "New codebase"

    fill_in "Name", with: @codebase.name
    fill_in "Url", with: @codebase.url
    click_on "Create Codebase"

    assert_text "Codebase was successfully created"
    click_on "Back"
  end

  test "should update Codebase" do
    visit codebase_url(@codebase)
    click_on "Edit this codebase", match: :first

    fill_in "Name", with: @codebase.name
    fill_in "Url", with: @codebase.url
    click_on "Update Codebase"

    assert_text "Codebase was successfully updated"
    click_on "Back"
  end

  test "should destroy Codebase" do
    visit codebase_url(@codebase)
    click_on "Destroy this codebase", match: :first

    assert_text "Codebase was successfully destroyed"
  end
end
