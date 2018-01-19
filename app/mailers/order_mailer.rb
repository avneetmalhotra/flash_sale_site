class OrderMailer < ApplicationMailer

  def confirmation_email(order_id)
    @order = Order.find_by(id: order_id)
    @user = @order.user
    @invoice_number = @order.try(:invoice_number)

    unless @order.nil? || @user.nil? || @invoice_number.nil?
      mail(to: @user.email, subject: default_i18n_subject(invoice_number: @invoice_number))
    end
  end
end
