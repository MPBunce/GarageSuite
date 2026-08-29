require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "builds social profile URLs from usernames" do
    assert_equal "https://www.instagram.com/auto-enterprise", social_profile_url(:instagram, "@auto-enterprise")
    assert_equal "https://x.com/autoenterprise", social_profile_url(:x, "autoenterprise")
    assert_equal "https://www.tiktok.com/@autoenterprise", social_profile_url(:tiktok, "@autoenterprise")
    assert_nil social_profile_url(:instagram, " ")
  end
end