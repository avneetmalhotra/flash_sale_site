class Deal < ApplicationRecord

  include Presentable

  ## ASSOCIATIONS
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: proc { |attributes| attributes[:avatar].blank? }

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

  validate :publishing_date_must_be_after_today, if: :publishing_date_changed?
  
  validate :associated_images_count, if: :has_publishing_date?

  validate :quantity_count, if: :has_publishing_date?

  validate :publishing_date_cannot_be_updated, on: :update, if: :publishing_date_changed?
  
  validate :maximum_number_of_deals_per_publishing_date, if: :has_publishing_date?

  ## CALLBACKS
  # when image is destroyed images.size changes only after update
  # so this callback verifies if image_count_valid
  after_update :ensure_images_count_valid, if: :has_publishing_date?

  ## SCOPE
  scope :deals_on_publishing_date, ->(date = Date.current) { where(publishing_date: date) }


  def has_publishing_date?
    publishing_date.present?
  end

  def publishability_errors
    issues = []
    unless has_publishing_date?
      issues << I18n.t(:publishng_date_absent, scope:[:deal, :error])
      
      if has_invalid_associated_images_count?
        issues << 'Image ' + I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i) 
      end

      if has_invalid_quantity_count?
        issues << 'Quantity ' + I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i)
      end
    end
    issues
  end

  private

    def publishing_date_must_be_after_today
      if has_publishing_date? && publishing_date <= Date.current
        errors[:publishing_date] << I18n.t(:publishing_date_must_be_after_today, scope: [:errors, :custom_validation], date: Date.current)
      end
    end

    def has_invalid_associated_images_count?
      images.size < ENV['published_deal_minimum_image_count'].to_i
    end

    def associated_images_count
      if has_invalid_associated_images_count?
        errors[:images] << I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i) 
      end
    end

    def has_invalid_quantity_count?
      quantity? && quantity < ENV['published_deal_minimum_quantity_count'].to_i
    end

    def quantity_count
      if has_invalid_quantity_count?
        errors[:quantity] << I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i)
      end
    end

    def publishing_date_cannot_be_updated
      if publishing_date_was.present?

        # publishing date cannot be changed 1.day before deal goes live ||
        # on the day of publish if it hasn't been published yet
        if (publishing_date_was == 1.day.after.to_date) || (start_at.nil? && publishing_date_was == Date.current)
          errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_h_hours_before_deal_goes_live, scope: [:errors, :custom_validation], h: ENV['hours_before_start_when_publishing_date_cannot_be_changed'])

        elsif start_at? && end_at?
          # publishing date cannot be changed when deal is live
          if Time.current.between?(start_at, end_at) 
            errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_for_live_deal, scope: [:errors, :custom_validation])
        
          # publishing date cannot be changed after deal has expired
          elsif end_at < Time.current
            errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_after_deal_expire, scope: [:errors, :custom_validation])
          end
        end
      
      end
    end

    def maximum_number_of_deals_per_publishing_date
      if self.class.deals_on_publishing_date(publishing_date).count >= ENV['maximum_number_of_deal_per_publishing_date'].to_i
        errors[:publishing_date] << I18n.t(:cannot_have_more_deals, scope: [:errors, :custom_validation], maximum_number_of_deals: ENV['maximum_number_of_deal_per_publishing_date'].to_i)
      end
    end

    def ensure_images_count_valid
      if has_invalid_associated_images_count?
        errors[:images] << I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i) 
        raise ActiveRecord::Rollback
      end
    end
end
