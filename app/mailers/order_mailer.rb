class OrderMailer < ApplicationMailer

  def confirmation_email(order_id)
    @order = Order.find_by(id: order_id)
    @user = @order.try(:user)

    send_email    
  end

  def cancellation_email(order_id)
    @order = Order.find_by(id: order_id)
    @user = @order.try(:user)

    send_email    
  end

  def delivery_email(order_id)
    @order = Order.find_by(id: order_id)
    @user = @order.try(:user)

    send_email    
  end

  def cancellation_by_admin_email(order_id)
    @order = Order.find_by(id: order_id)
    @user = @order.try(:user)

    send_email
  end

  private

    def send_email
      if @order.present?
        mail(to: @user.email, subject: default_i18n_subject(invoice_number: @order.invoice_number))
      end
    end

end
