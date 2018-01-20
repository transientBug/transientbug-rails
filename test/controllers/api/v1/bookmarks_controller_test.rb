require 'test_helper'

class Api::V1::BookmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @api_v1_bookmark = api_v1_bookmarks(:one)
  end

  test "should get index" do
    get api_v1_bookmarks_url, as: :json
    assert_response :success
  end

  test "should create api_v1_bookmark" do
    assert_difference('Api::V1::Bookmark.count') do
      post api_v1_bookmarks_url, params: { api_v1_bookmark: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show api_v1_bookmark" do
    get api_v1_bookmark_url(@api_v1_bookmark), as: :json
    assert_response :success
  end

  test "should update api_v1_bookmark" do
    patch api_v1_bookmark_url(@api_v1_bookmark), params: { api_v1_bookmark: {  } }, as: :json
    assert_response 200
  end

  test "should destroy api_v1_bookmark" do
    assert_difference('Api::V1::Bookmark.count', -1) do
      delete api_v1_bookmark_url(@api_v1_bookmark), as: :json
    end

    assert_response 204
  end
end
