require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "", email: "user.invalid",
                                         password: "foo", password_confirmation: "bar"}}
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  test "valid signup" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Heyar Konderiom", email: "user@valid.net",
                                         password: "Pass123Word", password_confirmation: "Pass123Word"}}
    end
    follow_redirect!
    assert_template 'users/show'
  end

  test "flash appears on valid signup" do
    post users_path, params: { user: { name: "Heyar Konderiom", email: "user2@valid.net",
                                       password: "Pass123Word", password_confirmation: "Pass123Word"}}
    follow_redirect!
    assert_not flash.empty?
  end
end