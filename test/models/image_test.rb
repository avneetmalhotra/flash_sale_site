require "test_helper"

class ImageTest < ActiveSupport::TestCase
  test 'invalid without avatar' do
    image = Image.new
    image.valid?
    assert_includes(image.errors[:avatar], "can't be blank")
  end

  test 'invalid with content tyoe other than jpeg, gif, png' do
    image = Image.new avatar_content_type: 'image/asn'
    image.valid?
    assert_includes(image.errors[:avatar_content_type], 'is invalid')
  end

  test 'invalid with image size mor than or equal to 5MB' do
    image = Image.new avatar_file_size: 9999999999
    image.valid?
    assert_includes(image.errors[:avatar_file_size], 'must be less than 5 MB')
  end
end
