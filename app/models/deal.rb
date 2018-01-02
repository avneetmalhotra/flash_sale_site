class Deal < ApplicationRecord

  include Presentable

  ## ASSOCIATIONS
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true

  ## VALIDATIONS
  with_options presence: true do
    validates :title, :description, :price, :discount_price, :quantity
  end

  with_options allow_blank: true do
    validates :title, uniqueness: { case_sensitive: false }
    
    validates :price, numericality: { greater_than_or_equal_to: ENV['minimum_price'].to_i }
    validates :discount_price, numericality: { greater_than_or_equal_to: ENV['minimum_discount_price'].to_i }
    
    validates :quantity, numericality: { 
      only_integer: true,
      greater_than_or_equal_to: 0 }
  end

  validates_with DiscountPriceValidator

  validate :publishing_date_must_be_after_today, on: :create, if: :has_publishing_date?
  
  # validates associated_images_count & quantity_count
  validate :publishability, if: :has_publishing_date?

  validate :publishing_date_cannot_be_updated, on: :update, if: :has_publishing_date?
  
  validate :maximum_number_of_deals_per_publishing_date, if: :has_publishing_date?

  ## SCOPE
  scope :deals_on_publishing_date, ->(date = Date.current) { where(publishing_date: date) }

  def has_publishing_date?
    publishing_date.present?
  end

  def publishable?
    has_publishing_date? && (images.size > ENV['published_deal_minimum_image_count'].to_i) && (quantity? && quantity > 10)
  end

  def publishability
    issues = []
    unless publishable?
      issues << associated_images_count
      issues << quantity_count
    end
    issues.compact
  end

  private

    def publishing_date_must_be_after_today
      if publishing_date < Date.current
        errors[:publishing_date] << I18n.t(:publishing_date_must_be_after_today, scope: [:errors, :custom_validation], date: Date.current)
      end
    end

    def associated_images_count
      if images.size < ENV['published_deal_minimum_image_count'].to_i
        error = I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i)
        errors[:images] << error
        'Image ' + error
      else
        nil
      end
    end

    def quantity_count
      if quantity? && quantity < ENV['published_deal_minimum_quantity_count'].to_i
        error = I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i)
        errors[:quantity] << error
        'Quantity ' + error
      else
        nil
      end
    end

    def publishing_date_cannot_be_updated
      # is start_at.present? then end_at should also be present
      if start_at.present? && publishing_date_changed?

        # publishing date cannot be changed 24.hours before deal goes live
        if (start_at > DateTime.current) && (start_at - DateTime.current < HOURS_BEFORE_START_WHEN_PUBLISHING_DATE_CANNOT_BE_CHANGED) 
          errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_h_hours_before_deal_goes_live, scope: [:errors, :custom_validation], h: 24)
        
        # publishing date cannot be changed when deal is live
        elsif (start_at < DateTime.current) && (end_at > DateTime.current) 
          errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_for_live_deal, scope: [:errors, :custom_validation])
        
        # publishing date cannot be changed after deal has expired
        elsif end_at < DateTime.current
          errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_after_deal_expire, scope: [:errors, :custom_validation])
        end
      end
    end

    def maximum_number_of_deals_per_publishing_date
      if self.class.deals_on_publishing_date(publishing_date).count >= ENV['maximum_number_of_deal_per_publishing_date'].to_i
        errors[:publishing_date] << I18n.t(:cannot_have_more_deals, scope: [:errors, :custom_validation], maximum_number_of_deals: ENV['maximum_number_of_deal_per_publishing_date'].to_i)
      end
    end
end
