class Deal < ApplicationRecord

  include Presentable

  ## ASSOCIATIONS
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true, reject_if: proc { |attributes| attributes[:avatar].blank? }

  has_many :line_items, dependent: :restrict_with_error

  ## VALIDATIONS
  with_options presence: true do
    validates :title, :description, :price, :discount_price, :quantity
  end

  with_options allow_blank: true do
    validates :title, uniqueness: { case_sensitive: false }
    
    validates :price, numericality: { greater_than_or_equal_to: ENV['minimum_price'].to_f }
    validates :discount_price, numericality: { greater_than_or_equal_to: ENV['minimum_discount_price'].to_f }
    
    validates :quantity, numericality: { 
      only_integer: true,
      greater_than_or_equal_to: 0 }
  end

  validates_with DiscountPriceValidator

  validate :publishing_date_must_be_after_today, if: :publishing_date_changed?
  
  validate :associated_images_count, if: :has_publishing_date?

  validate :quantity_count, if: :has_publishing_date?

  validate :publishing_date_cannot_be_updated, on: :update, if: [:publishing_date_changed?, :publishing_date_was]
  
  validate :maximum_number_of_deals_per_publishing_date, if: :has_publishing_date?

  ## CALLBACKS
  # when image is destroyed images.size changes only after update
  # so this callback verifies if image_count_valid
  after_update :ensure_images_count_valid, if: :has_publishing_date?
  before_destroy :ensure_deal_not_live_or_expired

  ## SCOPE
  scope :publishable_on, ->(date = Date.current) { where(publishing_date: date) }
  scope :live, ->{ where("start_at <= ? AND end_at >= ?", Time.current, Time.current) }
  scope :expired, ->{ where("end_at < ?", Time.current) }
  scope :future, -> { where(start_at: nil).where("publishing_date >= ?", Date.current) }
  scope :unpublished, ->{ where(publishing_date: nil) }
  scope :chronologically_by_end_at, ->{ order(:end_at) }
  scope :reverse_chronologically_by_end_at, ->{ order(end_at: :desc) }
  scope :search_by_title_and_description, ->(title, description) { where("title LIKE ? OR description LIKE ?", "%#{title}%", "%#{description}%") }

  def has_publishing_date?
    publishing_date.present?
  end

  def publishability_errors
    issues = []
      
    if has_invalid_associated_images_count?
      issues << 'Image ' + I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i) 
    end

    if has_invalid_quantity_count?
      issues << 'Quantity ' + I18n.t(:quantity_greater_than, scope: [:errors, :custom_validation], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i)
    end

    issues
  end

  def is_live?
    start_at.present? && end_at.present? && Time.current.between?(start_at, end_at)
  end

  def is_expired?
    start_at.present? && end_at.present? && end_at < Time.current
  end

  def pretty_errors
    errors.full_messages.join("<br>")
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
      # publishing date cannot be changed when deal is live
      if is_live? 
        errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_for_live_deal, scope: [:errors, :custom_validation])
    
      # publishing date cannot be changed after deal has expired
      elsif is_expired?
        errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_after_deal_expire, scope: [:errors, :custom_validation])
     
      # publishing date cannot be changed 24.hours before deal goes live
      elsif publishing_date_was.to_time - Time.current < HOURS_BEFORE_START_WHEN_PUBLISHING_DATE_CANNOT_BE_CHANGED
        errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_h_hours_before_deal_goes_live, scope: [:errors, :custom_validation], h: ENV['bumber_of_hours_before_start_when_publishing_date_cannot_be_changed'])
      end
    end

    def maximum_number_of_deals_per_publishing_date
      if self.class.publishable_on(publishing_date).count >= ENV['maximum_number_of_deal_per_publishing_date'].to_i
        errors[:publishing_date] << I18n.t(:cannot_have_more_deals, scope: [:errors, :custom_validation], maximum_number_of_deals: ENV['maximum_number_of_deal_per_publishing_date'].to_i)
      end
    end

    def ensure_images_count_valid
      if has_invalid_associated_images_count?
        errors[:images] << I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i) 
        raise ActiveRecord::Rollback
      end

    end

    def ensure_deal_not_live_or_expired
      if is_expired? || is_live?
        errors[:base] << I18n.t(:live_or_expired_deal_cannot_be_deleted, scope: [:deal, :errors])
        throw :abort
      end
    end
end
