class OrderMailer < ApplicationMailer

  def confirmation_email(order_id)
    @order = Order.find_by(id: order_id)
    @usr = @order.try(:user)

    if @order.present?
      mail(to: @user.email, subject: default_i18n_subject(invoice_number: @order.invoice_number))
    end
  end

  def cancellation_email(order_id)
    @order = Order.find_by(id: order_id)
    @user = @order.try(:user)

    if @order.present?
      mail(to: @user.email, subject: default_i18n_subject(invoice_number: @order.invoice_number))
    end
  end

end
