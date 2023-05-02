require "test_helper"

class PasswordResetTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
    ActionMailer::Base.deliveries.clear
  end
  test "password reset" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    #invalid email
    post password_resets_path, params: {password_reset: {email: " "}}
    assert_not flash.empty?
    assert_template 'password_resets/new'
    #valid email address
    post password_resets_path, params: {password_reset: {email: @user.email}}
    # check to make sure we made a new reset_digest for user
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    #password reset form
    user = assigns(:user)
    #wrong email
    get edit_password_reset_path(user.reset_token, email: " ")
    assert_redirected_to root_url
    #inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    #right mail, wrong token
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_url
    #right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    # select the hidden field
    assert_select "input[name=email][type=hidden][value=?]", user.email
    #Invalid password & confirmation
    patch password_reset_path(user.reset_token), params: {email: user.email,
                                                          user: {password: "bb",
                                                                 password_confirmation: "aa"}}
    assert_select 'div#error_explanation'
    #Empty password
    patch password_reset_path(user.reset_token), params: {email: user.email,
                                                              user: {password: "",
                                                                     password_confirmation: ""}}
    assert_select 'div#error_explanation'
    #Valid password and confirmation
    patch password_reset_path(user.reset_token), params: {email: user.email,
                                                          user: {password: "A1aA1aA1a",
                                                                 password_confirmation: "A1aA1aA1a"}}
    assert is_logged_in?
    assert_not flash.empty?
    assert_nil user.reload.reset_digest
    assert_redirected_to user
  end

  test "check expired reset token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: {email: @user.email}}
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(@user.reset_token), params: {email: @user.email,
                                        user: {password: "A1aA1aA1a",
                                               password_confirmation: "A1aA1aA1a"}}
    assert_response :redirect
    follow_redirect!
    assert_match /expire/i, response.body
  end
end
