require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "shows configured social profile links" do
    AppSetting.update_settings!(
      "instagram_username" => "@autoenterprise",
      "x_username" => "autoenterprise",
      "tiktok_username" => "@autoenterprise"
    )

    get root_path

    assert_response :success
    assert_includes response.body, 'href="https://www.instagram.com/autoenterprise"'
    assert_includes response.body, 'href="https://x.com/autoenterprise"'
    assert_includes response.body, 'href="https://www.tiktok.com/@autoenterprise"'
    assert_equal 3, response.body.scan(">@autoenterprise</span>").count
  end
end
