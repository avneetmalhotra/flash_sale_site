class OrderPresenter < Struct.new(:order)

  def cancellation_time
    if order.cancelled_at.nil?
      I18n.t(:not_cancelled, scope: :order)
    else
      order.cancelled_at
    end
  end

  def delivery_time
    if order.delivered_at.nil?
      I18n.t(:not_delivered, scope: :order)
    else
      order.delivered_at
    end
  end
end
