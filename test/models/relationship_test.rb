require "test_helper"

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @user1 = users(:michael)
    @user2 = users(:archer)
    @relationship = @user1.active_relationships.build(followed: @user2)
  end

  test "should be valid" do
    assert @relationship.valid?
  end

  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end
end
