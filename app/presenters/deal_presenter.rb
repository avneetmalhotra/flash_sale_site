class DealPresenter < Struct.new(:deal)

  def publishing_date
    if deal.publishing_date.nil?
      I18n.t(:no_date_set, scope: [:deal, :errors])
    else
      deal.publishing_date
    end
  end

  def start_time
    if deal.start_at.nil?
      I18n.t(:no_time_set, scope: [:deal, :errors] )
    else
      deal.start_at
    end
  end

  def end_time
    if deal.end_at.nil?
      I18n.t(:no_time_set, scope: [:deal, :errors] )
    else
      deal.end_at
    end 
  end

end
