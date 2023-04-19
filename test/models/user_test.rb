require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = User.new(name: "Valid", email: "valid@test.me",
                     password: "fOo12Barr", password_confirmation: "fOo12Barr")
  end

  test "should be valid" do
    user = User.new(name:"Valid", email:"valid@test.me")
    assert_not user.valid?
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 255 + "@test.me"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addrs = %w[user@test.me USER@test.me.em user@example.com
                    USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]

    valid_addrs.each do |valid_addr|
      @user.email = valid_addr
      assert @user.valid?, "#{valid_addr.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                            foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |inv_addr|
      @user.email = inv_addr
      assert_not @user.valid?, "#{inv_addr.inspect} should be invalid!"
    end
  end

  test "email should be unique" do
    dup_user = @user.dup
    @user.save

    assert_not dup_user.valid?
  end

  test "email should be downcased" do
    @user.email="HELLO@TEST.ME"
    assert @user.save
    @user.email = "HELLO@TEST.ME"
    @user.reload
    assert_equal "hello@test.me", @user.email
  end

  test "password shouldn't be blank" do
    @user.password = @user.password_confirmation = " " * 8
    assert_not @user.valid?
  end

  test "password should have minimum length" do
    @user.password = @user.password_confirmation = "a" * 7
    assert_not @user.valid?
  end

  test "password should be strong" do
    bad_pswds = %w[hellohello helloHello hello33hello Hello3hello]
    bad_pswds.each do |bad_pswd|
      @user.password = @user.password_confirmation = bad_pswd


      assert_not @user.valid?, "#{bad_pswd.inspect} should not be accepted!"
    end
  end

end
