class Deal < ApplicationRecord

  ## ASSOCIATIONS
  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images, allow_destroy: true

  ## VALIDATIONS
  with_options presence: true do
    validates :title, :description, :price, :discount_price, :quantity
  end

  with_options allow_blank: true do
    validates :title, uniqueness: { case_sensitive: false }
    
    validates :price, numericality: { greater_than_or_equal_to: 0.01 }
    validates :price, discount_price: true
    validates :discount_price, numericality: { greater_than_or_equal_to: 0.01 }
    
    validates :quantity, numericality: { 
      only_integer: true, 
      greater_than_or_equal_to: ENV['published_deal_minimum_quantity_count'].to_i }, if: :has_publishing_date?
    
    validates :publishing_date, format: {
      with: Regexp.new(ENV['date_regex'])
    }
  end

  validate :associated_images_count, if: :has_publishing_date?
  
  validate :publishing_date_must_be_after_today
  validate :publishing_date_cannot_be_updated, on: :update
  
  validate :maximum_number_of_deals_per_publishing_date
  

  def publishing_issues
    unless has_publishing_date?
      issues = []

      if images.size < ENV['published_deal_minimum_image_count'].to_i
        issues << I18n.t(:image_greater_than, scope: [:deal, :publishing_issues], image_count: ENV['published_deal_minimum_image_count'].to_i) 
      end

      if quantity.present? && ( quantity < ENV['published_deal_minimum_quantity_count'].to_i )
        issues << I18n.t(:quantity_greater_than, scope: [:deal, :publishing_issues], quantity_count: ENV['published_deal_minimum_quantity_count'].to_i)
      end
    end
    issues
  end

  def has_publishing_date?
    publishing_date.present?
  end

  private

    def publishing_date_cannot_be_updated
      unless publish_start_at.nil?
        if (DateTime.parse(publishing_date_was.strftime("%F")).to_time - publish_start_at.to_time) > 24.hours
          errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_h_hours_before_deal_goes_live, scope: [:errors, :custom_validation], h: 24)
        elsif (Time.current - publish_start_at.to_time) > 1.second
          errors[:publishing_date] << I18n.t(:publishing_date_cannot_be_changed_after_deal_expire, scope: [:errors, :custom_validation])
        end
      end
    end

    def maximum_number_of_deals_per_publishing_date
      if has_publishing_date? && self.class.where(publishing_date: publishing_date).count >= ENV['maximum_number_of_deal_per_publishing_date'].to_i
        errors[:publishing_date] << I18n.t(:cannot_have_more_deals, scope: [:errors, :custom_validation], deal_count: ENV['maximum_number_of_deal_per_publishing_date'].to_i)
      end
    end

    def publishing_date_must_be_after_today
      if has_publishing_date? && (publishing_date - Date.today).to_i < 1
        errors[:publishing_date] << I18n.t(:publishing_date_must_be_after_tomorrow, scope: [:errors, :custom_validation], date: Date.today)
      end
    end

    def associated_images_count
      if images.size > ENV['published_deal_image_count'].to_i
        errors[:images] << I18n.t(:image_greater_than, scope: [:errors, :custom_validation], image_count: ENV['published_deal_minimum_image_count'].to_i) 
      end
    end

end
