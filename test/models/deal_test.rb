require 'test_helper'

class DealTest < ActiveSupport::TestCase

  test 'invalid without title, description, price, discount_price, quantity' do
    deal = Deal.new
    deal.valid?
    assert_includes(deal.errors[:title], "can't be blank")
    assert_includes(deal.errors[:description], "can't be blank")
    assert_includes(deal.errors[:price], "can't be blank")
    assert_includes(deal.errors[:discount_price], "can't be blank")
    assert_includes(deal.errors[:quantity], "can't be blank")
    assert_equal(deal.pretty_errors, "Title can't be blank<br>Description can't be blank<br>Price can't be blank<br>Discount price can't be blank<br>Quantity can't be blank")
  end

  test 'invalid with duplicate title' do
    deal = Deal.new title: 'deal1'
    deal.valid?
    assert_includes(deal.errors[:title], 'has already been taken')
  end

  test 'invalid with price less than 0.01' do
    deal = Deal.new price: 0
    deal.valid?
    assert_includes(deal.errors[:price], 'must be greater than or equal to 0.01')
  end

  test 'invalid with discount price less than 0.01' do
    deal = Deal.new discount_price: 0
    deal.valid?
    assert_includes(deal.errors[:discount_price], 'must be greater than or equal to 0.01')
  end

  test 'invalid with non-integer quantity' do
    deal = Deal.new quantity: 3.4
    deal.valid?
    assert_includes(deal.errors[:quantity], 'must be an integer')
  end

  test 'invalid with quantity less than 0' do
    deal = Deal.new quantity: -4
    deal.valid?
    assert_includes(deal.errors[:quantity], 'must be greater than or equal to 0')
  end

  test 'invalid if discount_price is less tha price' do
    deal = Deal.new(discount_price: 23.3, price: 12.4)
    deal.valid?
    assert_includes(deal.errors[:discount_price], I18n.t(:discount_price_less_than_price, scope: [:errors, :custom_validation]))
  end

  test 'invalid if publishing date is not after 24 hours from now' do
    deal = Deal.new publishing_date: Date.current
    deal.valid?
    assert_includes(deal.errors[:publishing_date], I18n.t(:publishing_date_must_be_after_today, scope: [:errors, :custom_validation], date: Date.current))
  end

  test 'invalid if image count is less than 2 when publising date is present' do
    deal = Deal.new publishing_date: 2.day.after
    deal.valid?
    assert_includes(deal.errors[:images], I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i))
  end

  test 'invalid if quantity is less than 10 when publishing date is present' do
    deal = Deal.new publishing_date: 2.day.after, quantity: 2
    deal.valid?
    assert_includes(deal.errors[:quantity], I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i))
  end

  test 'publishing date cannot be updated if deal has expired' do
    deal = Deal.first
    deal.publishing_date = Time.current
    deal.valid?(:update)
    assert_includes(deal.errors[:publishing_date], I18n.t(:publishing_date_cannot_be_changed_after_deal_expire, scope: [:errors, :custom_validation]))
  end

  test 'publishing date cannot be updated for live deal' do
    deal = Deal.first
    deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
    deal.publishing_date = 4.day.after
    deal.valid?(:update)
    assert_includes(deal.errors[:publishing_date], I18n.t(:publishing_date_cannot_be_changed_for_live_deal, scope: [:errors, :custom_validation]))
  end

  test 'publishing date cannot be updated 24 hours before it goes live' do
    deal = Deal.first
    deal.update_columns(publishing_date: 1.day.after, start_at: 1.day.after, end_at: 2.day.after)
    deal.publishing_date = 4.day.after
    deal.valid?(:update)
    assert_includes(deal.errors[:publishing_date], I18n.t(:publishing_date_cannot_be_changed_h_hours_before_deal_goes_live, scope: [:errors, :custom_validation], h: ENV['bumber_of_hours_before_start_when_publishing_date_cannot_be_changed']))
  end

  test 'invalid if more than 2 deal per publishing date' do
    deal = Deal.new publishing_date: Date.new(2018, 2, 10)
    deal.valid?
    assert_includes(deal.errors[:publishing_date], I18n.t(:cannot_have_more_deals, scope: [:errors, :custom_validation], maximum_number_of_deals: ENV['maximum_number_of_deal_per_publishing_date'].to_i))
  end

  test 'update fails if images count in less than 2 on update of published deal' do
    deal = Deal.second
    image = deal.images.first
    assert_not deal.update(title: 'new_deal1', images_attributes: [{ id: image.id, avatar: image.avatar, _destroy: true }])
    assert_includes(deal.errors[:images], I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i))
  end

  test 'cannot destroy live deal' do
    deal = Deal.first
    deal.update_columns(publishing_date: Date.current, start_at: Time.current, end_at: 1.day.after)
    deal.line_items.delete_all
    assert_not deal.destroy
    assert_includes(deal.errors[:base], I18n.t(:live_or_expired_deal_cannot_be_deleted, scope: [:deal, :errors]))
  end

  test 'publishability errors' do
    deal = Deal.third
    errors = deal.publishability_errors
    assert_includes(errors, 'Image ' + I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i))
    assert_includes(errors, 'Quantity ' + I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i))
  end

end
