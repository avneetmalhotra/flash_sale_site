class OrderMailer < ApplicationMailer

  def confirmation_email(order_id)
    fetch_order
    fetch_user
    send_email    
  end

  def cancellation_email(order_id)
    fetch_order
    fetch_user
    send_email    
  end

  def delivery_email(order_id)
    fetch_order
    fetch_user
    send_email    
  end

  def cancellation_by_admin_email(order_id)
    fetch_order
    fetch_user
    send_email    
  end

  private

    def fetch_order
      @order = Order.find_by(id: order_id)
    end

    def fetch_user
      @user = @order.user
    end

    def send_email
      if @order.present?
        mail(to: @user.email, subject: default_i18n_subject(invoice_number: @order.invoice_number))
      end
    end

end
